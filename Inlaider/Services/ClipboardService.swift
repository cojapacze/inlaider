import Cocoa

class ClipboardService {

    static func copySelection() -> String? {
        let backup = backupPasteboard()
        let currentCounter = NSPasteboard.general.changeCount
        KeyboardService.simulateCmd(.c)
        usleep(150_000)
        let afterCounter = NSPasteboard.general.changeCount
        guard afterCounter > currentCounter else {
            return nil
        }
        let copied = getString();
        restorePasteboard(backup)
        return copied
    }

    static func backupPasteboard() -> [NSPasteboardItem] {
        (NSPasteboard.general.pasteboardItems ?? []).map { item in
            let clone = NSPasteboardItem()
            for type in item.types {
                if let data = item.data(forType: type) {
                    clone.setData(data, forType: type)
                }
            }
            return clone
        }
    }

    static func clearPasteboard() {
        let pb = NSPasteboard.general
        pb.clearContents()
    }

    static func getString() -> String? {
        NSPasteboard.general.string(forType: .string)
    }

    static func setString(_ string: String) {
        let pb = NSPasteboard.general
        clearPasteboard()
        pb.setString(string, forType: .string)
    }

    static func restorePasteboard(_ items: [NSPasteboardItem]) {
        let pb = NSPasteboard.general
        clearPasteboard()
        pb.writeObjects(items)
    }
}
