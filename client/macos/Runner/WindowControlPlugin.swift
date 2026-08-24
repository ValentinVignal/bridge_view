import Cocoa
import FlutterMacOS

/// Implements [WindowControlApi] by toggling fullscreen on the app's main window.
final class WindowControlPlugin: NSObject, WindowControlApi {

    private weak var window: NSWindow?

    init(window: NSWindow) {
        self.window = window
    }

    static func register(with registrar: FlutterPluginRegistrar, window: NSWindow) {
        let instance = WindowControlPlugin(window: window)
        WindowControlApiSetup.setUp(binaryMessenger: registrar.messenger, api: instance)
    }

    func enterFullScreen() throws {
        guard let window = window, !window.styleMask.contains(.fullScreen) else { return }
        window.toggleFullScreen(nil)
    }

    func exitFullScreen() throws {
        guard let window = window, window.styleMask.contains(.fullScreen) else { return }
        window.toggleFullScreen(nil)
    }
}
