import Cocoa

class InputsService {

    static var lastAppPID: pid_t = 0
    static var lastAppName: String = ""
    static var lastAppIcon: NSImage?

    static func getInputSelection() -> String? {
        lastAppPID = 0
        lastAppName = ""
        lastAppIcon = nil
        let lastAppPID = NSWorkspace.shared.frontmostApplication?.processIdentifier ?? 0
        guard ProcessInfo.processInfo.processIdentifier != lastAppPID else { return nil }
        self.lastAppPID = lastAppPID;
        self.lastAppName = NSWorkspace.shared.frontmostApplication?.localizedName ?? ""
        self.lastAppIcon = NSWorkspace.shared.frontmostApplication?.icon ?? nil
        guard let selection = ClipboardService.copySelection() else { return nil }
        return selection
    }

    static func setInputSelection(_ output: String) {
        let backup = ClipboardService.backupPasteboard()
        self.setInputFocus()
        usleep(150_000)
        ClipboardService.setString(output)
        KeyboardService.simulateCmd(.v)
        usleep(150_000)
        let selectionAfter = ClipboardService.copySelection()
        if (selectionAfter == nil) {
            // Restore the clipboard only after successfully pasting (which clears the selection).
            ClipboardService.restorePasteboard(backup)
        }
    }

    static func setInputFocus() {
        WindowsService.restoreFocus(self.lastAppPID)
    }
}
