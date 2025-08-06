import SwiftUI
import AppKit

final class AboutWindowController {
    static let shared = AboutWindowController()
    private var window: NSWindow?

    private init() {}

    func show() {
        if window == nil {
            let view = AboutView()
            let hosting = NSHostingController(rootView: view)

            let panel = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: 420, height: 100),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )

            panel.contentViewController = hosting
            panel.isReleasedWhenClosed = false
            panel.collectionBehavior = [.fullScreenAuxiliary]
            panel.level = .floating
            panel.standardWindowButton(.miniaturizeButton)?.isHidden = true
            panel.standardWindowButton(.zoomButton)?.isHidden = true

            hosting.view.layoutSubtreeIfNeeded()
            let fittingSize = hosting.view.fittingSize
            var frame = panel.frame
            frame.size.height = fittingSize.height
            panel.setFrame(frame, display: false)

            center(panel, on: NSApp.mainWindow?.screen ?? NSScreen.main)

            self.window = panel
        }

        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }

    private func appName() -> String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ??
        ProcessInfo.processInfo.processName
    }

    private func center(_ window: NSWindow, on screen: NSScreen?) {
        guard let screen = screen else {
            window.center()
            return
        }
        let visible = screen.visibleFrame
        let size = window.frame.size
        let origin = NSPoint(
            x: visible.midX - size.width / 2.0,
            y: visible.midY - size.height / 2.0
        )
        window.setFrame(NSRect(origin: origin, size: size), display: true)
    }
}
#Preview {
    AboutView()
}
