package com.example.bridge_view_client

import android.media.MediaCodec
import android.media.MediaFormat
import android.view.Surface
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.TextureRegistry
import java.nio.ByteBuffer

/**
 * Flutter plugin that exposes hardware H.264 decoding via Android's [MediaCodec].
 *
 * Channel: "bridge_view/h264_renderer"
 * Methods:
 *   initialize(width: Int, height: Int) -> Long  (Flutter texture ID)
 *   decodeFrame(frameData: ByteArray, isKeyframe: Boolean) -> null
 *   dispose() -> null
 *
 * The plugin lazily starts [MediaCodec] on the first keyframe so it can extract
 * SPS/PPS from the Annex-B bit stream and supply them as codec-specific data (CSD),
 * which maximizes compatibility across Android devices.
 */
class H264RendererPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    private lateinit var channel: MethodChannel
    private lateinit var textureRegistry: TextureRegistry

    private var textureEntry: TextureRegistry.SurfaceTextureEntry? = null
    private var surface: Surface? = null
    private var codec: MediaCodec? = null

    private var pendingWidth = 0
    private var pendingHeight = 0
    private var codecStarted = false

    // -------------------------------------------------------------------------
    // FlutterPlugin
    // -------------------------------------------------------------------------

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        textureRegistry = binding.textureRegistry
        channel = MethodChannel(binding.binaryMessenger, "bridge_view/h264_renderer")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        releaseCodec()
    }

    // -------------------------------------------------------------------------
    // MethodCallHandler
    // -------------------------------------------------------------------------

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialize" -> {
                val width = call.argument<Int>("width") ?: 1920
                val height = call.argument<Int>("height") ?: 1080
                result.success(initialize(width, height))
            }
            "decodeFrame" -> {
                val data = call.argument<ByteArray>("frameData")
                val isKeyframe = call.argument<Boolean>("isKeyframe") ?: false
                if (data != null) decodeFrame(data, isKeyframe)
                result.success(null)
            }
            "dispose" -> {
                releaseCodec()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    // -------------------------------------------------------------------------
    // Implementation
    // -------------------------------------------------------------------------

    private fun initialize(width: Int, height: Int): Long {
        releaseCodec()
        pendingWidth = width
        pendingHeight = height
        codecStarted = false

        val entry = textureRegistry.createSurfaceTexture()
        entry.surfaceTexture().setDefaultBufferSize(width, height)
        textureEntry = entry
        surface = Surface(entry.surfaceTexture())
        return entry.id()
    }

    private fun decodeFrame(data: ByteArray, isKeyframe: Boolean) {
        // Start the codec lazily on the first keyframe so we have SPS/PPS.
        if (!codecStarted && isKeyframe) {
            startCodec(data)
        }
        val c = codec ?: return

        val inputIdx = c.dequeueInputBuffer(10_000L)
        if (inputIdx >= 0) {
            val buf = c.getInputBuffer(inputIdx) ?: return
            buf.clear()
            val frameToWrite = if (data.size <= buf.capacity()) data else data.copyOfRange(0, buf.capacity())
            buf.put(frameToWrite)
            val flags = if (isKeyframe) MediaCodec.BUFFER_FLAG_KEY_FRAME else 0
            c.queueInputBuffer(inputIdx, 0, frameToWrite.size, System.nanoTime() / 1_000L, flags)
        }

        // Drain any decoded output frames and render them to the Surface.
        val info = MediaCodec.BufferInfo()
        var outIdx = c.dequeueOutputBuffer(info, 0L)
        while (outIdx >= 0) {
            c.releaseOutputBuffer(outIdx, /* render= */ true)
            outIdx = c.dequeueOutputBuffer(info, 0L)
        }
    }

    /**
     * Parses SPS and PPS NAL units from [keyframeData] and uses them as CSD
     * when configuring [MediaCodec], then starts the decoder.
     */
    private fun startCodec(keyframeData: ByteArray) {
        val nalUnits = parseAnnexBNalUnits(keyframeData)
        val sps = nalUnits.firstOrNull { it.isNotEmpty() && (it[0].toInt() and 0x1f) == 7 }
        val pps = nalUnits.firstOrNull { it.isNotEmpty() && (it[0].toInt() and 0x1f) == 8 }

        val format = MediaFormat.createVideoFormat(
            MediaFormat.MIMETYPE_VIDEO_AVC, pendingWidth, pendingHeight,
        )
        format.setInteger(MediaFormat.KEY_MAX_INPUT_SIZE, pendingWidth * pendingHeight * 3 / 2)
        if (sps != null) format.setByteBuffer("csd-0", ByteBuffer.wrap(withStartCode(sps)))
        if (pps != null) format.setByteBuffer("csd-1", ByteBuffer.wrap(withStartCode(pps)))

        try {
            val c = MediaCodec.createDecoderByType(MediaFormat.MIMETYPE_VIDEO_AVC)
            c.configure(format, surface, null, 0)
            c.start()
            codec = c
            codecStarted = true
        } catch (e: Exception) {
            android.util.Log.e("H264RendererPlugin", "Failed to start codec: $e")
        }
    }

    private fun releaseCodec() {
        try {
            codec?.stop()
            codec?.release()
        } catch (_: Exception) {}
        codec = null
        codecStarted = false

        surface?.release()
        surface = null
        textureEntry?.release()
        textureEntry = null
    }

    // -------------------------------------------------------------------------
    // Annex-B helpers
    // -------------------------------------------------------------------------

    /**
     * Splits an H.264 Annex-B bitstream into individual raw NAL unit payloads
     * (start codes removed).
     */
    private fun parseAnnexBNalUnits(data: ByteArray): List<ByteArray> {
        val units = mutableListOf<ByteArray>()
        var searchFrom = 0
        while (searchFrom < data.size) {
            val scPos = findStartCode(data, searchFrom) ?: break
            val scLen = startCodeLength(data, scPos)
            val nalStart = scPos + scLen
            val nextSc = findStartCode(data, nalStart)
            val nalEnd = trimTrailingZeros(data, nalStart, nextSc ?: data.size)
            if (nalEnd > nalStart) {
                units.add(data.copyOfRange(nalStart, nalEnd))
            }
            searchFrom = nextSc ?: break
        }
        return units
    }

    /** Returns the index of the first start code at or after [from], or null. */
    private fun findStartCode(data: ByteArray, from: Int): Int? {
        val limit = data.size - 2
        for (i in from..limit) {
            if (data[i] == 0.toByte() && data[i + 1] == 0.toByte()) {
                if (data[i + 2] == 1.toByte()) return i
                if (i + 3 < data.size && data[i + 2] == 0.toByte() && data[i + 3] == 1.toByte()) return i
            }
        }
        return null
    }

    /** Returns 3 for a 3-byte start code, 4 for a 4-byte start code. */
    private fun startCodeLength(data: ByteArray, pos: Int): Int =
        if (pos + 3 < data.size && data[pos + 2] == 0.toByte()) 4 else 3

    /**
     * Returns the effective end of a NAL unit, trimming the leading-zero byte
     * that belongs to the next 4-byte start code prefix.
     */
    private fun trimTrailingZeros(data: ByteArray, nalStart: Int, rawEnd: Int): Int {
        var end = rawEnd
        while (end > nalStart + 1 && data[end - 1] == 0.toByte()) end--
        return end
    }

    /** Prepends a 4-byte Annex-B start code to [nalUnit]. */
    private fun withStartCode(nalUnit: ByteArray): ByteArray {
        val result = ByteArray(4 + nalUnit.size)
        result[2] = 0; result[3] = 1  // 00 00 00 01
        nalUnit.copyInto(result, 4)
        return result
    }
}
