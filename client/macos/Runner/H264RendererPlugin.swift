import Cocoa
import CoreMedia
import CoreVideo
import FlutterMacOS
import VideoToolbox

// MARK: - FlutterTexture

/// Holds the latest decoded pixel buffer and vends it to the Flutter compositor.
private final class H264DecoderTexture: NSObject, FlutterTexture {
    private let lock = NSLock()
    private var _pixelBuffer: CVPixelBuffer?

    func update(_ buffer: CVPixelBuffer) {
        lock.lock()
        _pixelBuffer = buffer
        lock.unlock()
    }

    func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
        lock.lock()
        defer { lock.unlock() }
        guard let buf = _pixelBuffer else { return nil }
        return Unmanaged.passRetained(buf)
    }
}

// MARK: - Plugin

/// Flutter plugin that exposes hardware H.264 decoding via macOS VideoToolbox.
///
/// Channel: "bridge_view/h264_renderer"
/// Methods:
///   initialize(width: Int, height: Int) -> Int64  (Flutter texture ID)
///   decodeFrame(frameData: FlutterStandardTypedData, isKeyframe: Bool) -> null
///   dispose() -> null
///
/// Frames must be supplied in H.264 Annex-B format (start-code prefixed).
/// The plugin extracts SPS/PPS from the first keyframe to build the
/// CMVideoFormatDescription required by VTDecompressionSession.
final class H264RendererPlugin: NSObject, FlutterPlugin {

    // -------------------------------------------------------------------------
    // Registration
    // -------------------------------------------------------------------------

    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "bridge_view/h264_renderer",
            binaryMessenger: registrar.messenger
        )
        let instance = H264RendererPlugin(textureRegistry: registrar.textures)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    // -------------------------------------------------------------------------
    // State
    // -------------------------------------------------------------------------

    private let textureRegistry: FlutterTextureRegistry
    private var texture: H264DecoderTexture?
    private var textureId: Int64 = -1

    private var session: VTDecompressionSession?
    private var formatDescription: CMVideoFormatDescription?

    private var pendingWidth: Int32 = 0
    private var pendingHeight: Int32 = 0

    /// Backing store kept alive for the duration of each synchronous decode call.
    private var avccData = Data()

    // -------------------------------------------------------------------------
    // Init
    // -------------------------------------------------------------------------

    private init(textureRegistry: FlutterTextureRegistry) {
        self.textureRegistry = textureRegistry
    }

    // -------------------------------------------------------------------------
    // FlutterPlugin
    // -------------------------------------------------------------------------

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            guard let args = call.arguments as? [String: Any],
                  let width = args["width"] as? Int,
                  let height = args["height"] as? Int
            else {
                result(FlutterError(code: "INVALID_ARGS", message: "width/height required", details: nil))
                return
            }
            result(initialize(width: Int32(width), height: Int32(height)))

        case "decodeFrame":
            guard let args = call.arguments as? [String: Any],
                  let typedData = args["frameData"] as? FlutterStandardTypedData
            else {
                result(nil)
                return
            }
            let isKeyframe = args["isKeyframe"] as? Bool ?? false
            decodeFrame(typedData.data, isKeyframe: isKeyframe)
            result(nil)

        case "dispose":
            releaseSession()
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // -------------------------------------------------------------------------
    // Implementation
    // -------------------------------------------------------------------------

    private func initialize(width: Int32, height: Int32) -> Int64 {
        releaseSession()
        pendingWidth = width
        pendingHeight = height

        let tex = H264DecoderTexture()
        texture = tex
        textureId = textureRegistry.register(tex)
        return textureId
    }

    private func decodeFrame(_ data: Data, isKeyframe: Bool) {
        if isKeyframe && session == nil {
            setupSession(from: data)
        }
        guard let sess = session, let formatDesc = formatDescription else { return }

        guard let sampleBuffer = makeSampleBuffer(from: data, formatDescription: formatDesc) else {
            return
        }

        var infoFlags = VTDecodeInfoFlags()
        VTDecompressionSessionDecodeFrame(
            sess,
            sampleBuffer: sampleBuffer,
            flags: [],            // synchronous
            frameRefcon: nil,
            infoFlagsOut: &infoFlags
        )
    }

    // -------------------------------------------------------------------------
    // Session setup
    // -------------------------------------------------------------------------

    private func setupSession(from keyframe: Data) {
        guard let (sps, pps) = extractSPSAndPPS(from: keyframe) else { return }

        let formatDesc = sps.withUnsafeBytes { spsPtr in
            pps.withUnsafeBytes { ppsPtr in
                createFormatDescription(
                    spsBytes: spsPtr.bindMemory(to: UInt8.self).baseAddress!,
                    spsSize: sps.count,
                    ppsBytes: ppsPtr.bindMemory(to: UInt8.self).baseAddress!,
                    ppsSize: pps.count
                )
            }
        }
        guard let desc = formatDesc else { return }
        formatDescription = desc

        let imageAttribs: [CFString: Any] = [
            kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey: pendingWidth,
            kCVPixelBufferHeightKey: pendingHeight,
            kCVPixelBufferMetalCompatibilityKey: true,
        ]

        var outputCallback = VTDecompressionOutputCallbackRecord(
            decompressionOutputCallback: { refCon, _, status, _, imageBuffer, _, _ in
                guard let refCon = refCon,
                      status == noErr,
                      let imageBuffer = imageBuffer else { return }
                let plugin = Unmanaged<H264RendererPlugin>.fromOpaque(refCon).takeUnretainedValue()
                plugin.onDecodedFrame(imageBuffer)
            },
            decompressionOutputRefCon: Unmanaged.passUnretained(self).toOpaque()
        )

        var newSession: VTDecompressionSession?
        let createStatus = VTDecompressionSessionCreate(
            allocator: kCFAllocatorDefault,
            formatDescription: desc,
            decoderSpecification: nil,
            imageBufferAttributes: imageAttribs as CFDictionary,
            outputCallback: &outputCallback,
            decompressionSessionOut: &newSession
        )
        if createStatus == noErr {
            session = newSession
        }
    }

    private func createFormatDescription(
        spsBytes: UnsafePointer<UInt8>, spsSize: Int,
        ppsBytes: UnsafePointer<UInt8>, ppsSize: Int
    ) -> CMVideoFormatDescription? {
        let paramSets: [UnsafePointer<UInt8>] = [spsBytes, ppsBytes]
        let paramSizes: [Int] = [spsSize, ppsSize]
        var desc: CMVideoFormatDescription?
        let status = CMVideoFormatDescriptionCreateFromH264ParameterSets(
            allocator: kCFAllocatorDefault,
            parameterSetCount: 2,
            parameterSetPointers: paramSets,
            parameterSetSizes: paramSizes,
            nalUnitHeaderLength: 4,
            formatDescriptionOut: &desc
        )
        return status == noErr ? desc : nil
    }

    // -------------------------------------------------------------------------
    // Decode output callback
    // -------------------------------------------------------------------------

    private func onDecodedFrame(_ imageBuffer: CVImageBuffer) {
        texture?.update(imageBuffer as CVPixelBuffer)
        if textureId >= 0 {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.textureRegistry.textureFrameAvailable(self.textureId)
            }
        }
    }

    // -------------------------------------------------------------------------
    // CMSampleBuffer construction (Annex-B → AVCC)
    // -------------------------------------------------------------------------

    /// Converts an Annex-B bitstream to AVCC (4-byte length-prefixed NAL units)
    /// and wraps the result in a CMSampleBuffer.
    private func makeSampleBuffer(
        from data: Data,
        formatDescription: CMVideoFormatDescription
    ) -> CMSampleBuffer? {
        avccData = annexBToAVCC(data)
        guard !avccData.isEmpty else { return nil }

        let blockBuffer = avccData.withUnsafeBytes { ptr -> CMBlockBuffer? in
            // Allocate a CoreMedia-managed block and copy our data into it.
            let memory = malloc(avccData.count)!
            _ = memcpy(memory, ptr.baseAddress!, avccData.count)
            var bb: CMBlockBuffer?
            let status = CMBlockBufferCreateWithMemoryBlock(
                allocator: kCFAllocatorDefault,
                memoryBlock: memory,
                blockLength: avccData.count,
                blockAllocator: kCFAllocatorMalloc, // CoreMedia will call free()
                customBlockSource: nil,
                offsetToData: 0,
                dataLength: avccData.count,
                flags: 0,
                blockBufferOut: &bb
            )
            return status == kCMBlockBufferNoErr ? bb : nil
        }
        guard let bb = blockBuffer else { return nil }

        var sampleBuffer: CMSampleBuffer?
        CMSampleBufferCreate(
            allocator: kCFAllocatorDefault,
            dataBuffer: bb,
            dataReady: true,
            makeDataReadyCallback: nil,
            refcon: nil,
            formatDescription: formatDescription,
            sampleCount: 1,
            sampleTimingEntryCount: 0,
            sampleTimingArray: nil,
            sampleSizeEntryCount: 0,
            sampleSizeArray: nil,
            sampleBufferOut: &sampleBuffer
        )
        return sampleBuffer
    }

    /// Converts an H.264 Annex-B bitstream to AVCC format (4-byte big-endian
    /// length prefix per NAL unit, no start codes).
    private func annexBToAVCC(_ data: Data) -> Data {
        let bytes = [UInt8](data)
        var result = Data()
        var i = 0
        while i < bytes.count {
            guard let scPos = findStartCode(bytes, from: i) else { break }
            let scLen = startCodeLength(bytes, at: scPos)
            let nalStart = scPos + scLen
            let nextSc = findStartCode(bytes, from: nalStart)
            var nalEnd = nextSc ?? bytes.count
            while nalEnd > nalStart + 1 && bytes[nalEnd - 1] == 0 { nalEnd -= 1 }
            let nalLen = nalEnd - nalStart
            if nalLen > 0 {
                var length = UInt32(nalLen).bigEndian
                result.append(contentsOf: withUnsafeBytes(of: &length) { Data($0) })
                result.append(contentsOf: bytes[nalStart..<nalEnd])
            }
            i = nextSc ?? bytes.count
        }
        return result
    }

    // -------------------------------------------------------------------------
    // SPS/PPS extraction
    // -------------------------------------------------------------------------

    /// Extracts the first SPS and PPS NAL unit payloads (without start codes)
    /// from an Annex-B keyframe.
    private func extractSPSAndPPS(from data: Data) -> (Data, Data)? {
        let bytes = [UInt8](data)
        var sps: Data?
        var pps: Data?
        var i = 0
        while i < bytes.count {
            guard let scPos = findStartCode(bytes, from: i) else { break }
            let scLen = startCodeLength(bytes, at: scPos)
            let nalStart = scPos + scLen
            guard nalStart < bytes.count else { break }
            let nalType = Int(bytes[nalStart]) & 0x1f
            let nextSc = findStartCode(bytes, from: nalStart + 1)
            var nalEnd = nextSc ?? bytes.count
            while nalEnd > nalStart + 1 && bytes[nalEnd - 1] == 0 { nalEnd -= 1 }
            if nalEnd > nalStart {
                switch nalType {
                case 7: sps = Data(bytes[nalStart..<nalEnd])
                case 8: pps = Data(bytes[nalStart..<nalEnd])
                default: break
                }
            }
            if sps != nil && pps != nil { break }
            i = nextSc ?? bytes.count
        }
        guard let s = sps, let p = pps else { return nil }
        return (s, p)
    }

    // -------------------------------------------------------------------------
    // Annex-B helpers
    // -------------------------------------------------------------------------

    private func findStartCode(_ bytes: [UInt8], from: Int) -> Int? {
        let limit = bytes.count - 2
        guard from <= limit else { return nil }
        for i in from...limit {
            if bytes[i] == 0 && bytes[i + 1] == 0 {
                if bytes[i + 2] == 1 { return i }
                if i + 3 < bytes.count && bytes[i + 2] == 0 && bytes[i + 3] == 1 { return i }
            }
        }
        return nil
    }

    private func startCodeLength(_ bytes: [UInt8], at pos: Int) -> Int {
        pos + 3 < bytes.count && bytes[pos + 2] == 0 ? 4 : 3
    }

    // -------------------------------------------------------------------------
    // Teardown
    // -------------------------------------------------------------------------

    private func releaseSession() {
        if let sess = session {
            VTDecompressionSessionInvalidate(sess)
            session = nil
        }
        formatDescription = nil
        if textureId >= 0 {
            textureRegistry.unregisterTexture(textureId)
            textureId = -1
        }
        texture = nil
    }
}
