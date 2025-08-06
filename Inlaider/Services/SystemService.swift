import Combine
import AppKit

enum AccessibilityPermission {
    private static var tccTrusted: Bool {
        let opts: [String: Any] = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: false]
        return AXIsProcessTrustedWithOptions(opts as CFDictionary)
    }

    static var isGranted: Bool {
        guard tccTrusted else { return false }
        return CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: true) != nil
    }

    static func request() {
        let opts: [String: Any] = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true]
        _ = AXIsProcessTrustedWithOptions(opts as CFDictionary)
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }
}

class SystemService: ObservableObject {
    static let shared = SystemService()
    @Published var accessGranted: Bool = AccessibilityPermission.isGranted
    private var cancellable: AnyCancellable?

    private init() {
        let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
        cancellable = timer.sink { [weak self] _ in
            guard let self = self else { return }
            self.accessGranted = AccessibilityPermission.isGranted
        }
    }
}
