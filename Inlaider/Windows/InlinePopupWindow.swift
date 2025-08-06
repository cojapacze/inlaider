import SwiftUI
import SwiftData

@MainActor
final class InlinePopupWindow {
    static let shared = InlinePopupWindow()
    private let modelContext: ModelContext = InlaiderApp.sharedModelContainer.mainContext
    private var window: NSWindow?
    
    var isVisible: Bool {
        return window?.isVisible ?? false
    }
    
    func close() {
        self.window?.close()
    }

    func focus() {
        NSApp.activate(ignoringOtherApps: true)
        if window == nil {
            return
        }
        self.window?.makeKeyAndOrderFront(nil)
        self.window?.makeMain()
        self.window?.orderFrontRegardless()
    }

    func present(
        inputText: String,
        onExecute: @escaping (String) -> Void,
        onCancel: @escaping () -> Void)
    {
        
        if window == nil {
            window = NSWindow(
                contentRect: .init(x: 0, y: 0, width: 440, height: 220),
                styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
                backing: .buffered, defer: false)
            window?.isReleasedWhenClosed = false
            window?.level = .floating
            window?.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            window?.titleVisibility = .hidden
            window?.hidesOnDeactivate = false
            window?.hasShadow = true
            window?.titlebarAppearsTransparent = true
            let accessory = NSTitlebarAccessoryViewController()
            accessory.layoutAttribute = .top
            accessory.view = NSHostingView(
                rootView: CreditsTitleAccessory()
            )
            window?.addTitlebarAccessoryViewController(accessory)
            window?.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            window?.level = .floating
            window?.titlebarAppearsTransparent = true
            NotificationCenter.default.addObserver(
                forName: NSWindow.didBecomeKeyNotification,
                object: window,
                queue: .main
            ) {
                [weak self] _ in
                    Task { @MainActor in
                        self?.window?.alphaValue = 1
                    }
            }
            NotificationCenter.default.addObserver(
                forName: NSWindow.didResignKeyNotification,
                object: window,
                queue: .main
            ) {
                [weak self] _ in
                    Task { @MainActor in
                        self?.window?.alphaValue = 0.7
                    }
            }
        }
        
        if let screen = NSScreen.screens.first(where: { $0.frame.contains(NSEvent.mouseLocation) }) {
            let w = window!
            let f = screen.visibleFrame
            w.setFrameOrigin(.init(
                x: f.midX - w.frame.width / 2,
                y: f.midY - w.frame.height / 2))
        }
        window?.undoManager?.removeAllActions()
        window?.contentView = NSHostingView(
            rootView: InlinePopupView(
                inputText: inputText,
                onExecute: { cmd in
                    onExecute(cmd)
                    self.window?.orderOut(nil)
                },
                onCancel: {
                    onCancel()
                    self.window?.orderOut(nil)
                }).environment(\.modelContext, modelContext))
        NSApp.activate(ignoringOtherApps: true)
        self.window?.makeKeyAndOrderFront(nil)
        self.window?.makeMain()
        self.window?.orderFrontRegardless()
    }
}

#Preview {
    CreditsTitleAccessory()
    InlinePopupView(
        inputText: "The quick brown fox jumps over the lazy dog",
        onExecute: { print("Result: \($0)") },
        onCancel: { print("Cancelled") }
    )
}
