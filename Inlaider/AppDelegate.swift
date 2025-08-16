import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var splashWC: NSWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        showSplash()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.closeSplash()
        }
    }

    func showSplash() {
        let host = NSHostingController(rootView: SplashView())
        let window = NSWindow(contentViewController: host)

        let splashSize = NSSize(width: 420, height: 300)
        window.setContentSize(splashSize)

        window.styleMask = [.titled, .fullSizeContentView]
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isOpaque = false
        window.backgroundColor = .clear
        window.isMovableByWindowBackground = true
        window.level = .floating // keeps it above while loading

        splashWC = NSWindowController(window: window)
        splashWC?.showWindow(nil)

        window.center()
    }

    func closeSplash() {
        splashWC?.close()
        splashWC = nil
    }
}
