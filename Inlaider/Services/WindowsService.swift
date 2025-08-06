import Cocoa

class WindowsService {
    static func restoreFocus(_ lastAppPID: Int32) {
       if let app = NSRunningApplication(processIdentifier: lastAppPID) {
           app.activate(options: [.activateAllWindows])
       }
   }
}

func showErrorAlert(error: Error) {
    let alert = NSAlert()
    alert.messageText = NSLocalizedString("error.title", comment: "Error message title")
    alert.informativeText = error.localizedDescription
    alert.alertStyle = .warning
    alert.addButton(withTitle: NSLocalizedString("ok", comment: "Error message ok button caption"))
    alert.runModal()
}
