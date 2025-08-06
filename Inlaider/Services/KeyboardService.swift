import Cocoa

enum Keycode: CGKeyCode {
    case c = 0x08
    case v = 0x09
}

class KeyboardService {
    public static func simulateCmd(_ key: Keycode) {
        guard let src = CGEventSource(stateID: .hidSystemState) else { return }

        let down = CGEvent(keyboardEventSource: src, virtualKey: key.rawValue, keyDown: true)
        let up   = CGEvent(keyboardEventSource: src, virtualKey: key.rawValue, keyDown: false)

        down?.flags = .maskCommand
        up?.flags = .maskCommand

        down?.post(tap: .cghidEventTap)
        up?.post(tap: .cghidEventTap)
    }
}
