import SwiftUI

struct MenuBarExtraInlaider: Scene {
    @Environment(\.openSettings) private var openSettings
    private let commandHandler: CommandHandler = .shared

    var body: some Scene {
        MenuBarExtra(NSLocalizedString("appName", comment: "App name in Menu Bar Extra"), systemImage: "rectangle.and.pencil.and.ellipsis") {
            Button(NSLocalizedString("show", comment: "Show Inlaider popup button caption in Menu Bar Extra"), systemImage: "dock.rectangle") {
                commandHandler.showInputAssistant()
            }
            .globalKeyboardShortcut(.showInputAssistant)

            Divider()

            Button(NSLocalizedString("settings", comment: "Show Settings window button caption in Menu Bar Extra"), systemImage: "gear") {
                openSettings()
                if let settingsWindow = NSApp.windows.first(where: { String($0.identifier?.rawValue ?? "") == "com_apple_SwiftUI_Settings_window" }) {
                    settingsWindow.makeKeyAndOrderFront(nil)
                    NSApp.activate(ignoringOtherApps: true)
                }
            }

            Button(NSLocalizedString("about", comment: "About button caption in Menu Bar Extra")) {
                AboutWindowController.shared.show()
            }

            Button(NSLocalizedString("quit", comment: "Quit app button caption in Menu Bar Extra")) {
                NSApp.terminate(nil)
            }
            .keyboardShortcut("Q", modifiers: [.command])
        }
    }
}
