import Cocoa
import ApplicationServices
import KeyboardShortcuts
import SwiftUI
import SwiftData

@MainActor
final class CommandHandler: ObservableObject {
    static let shared = CommandHandler()
    private let systemService = SystemService.shared
    private let modelContext: ModelContext = InlaiderApp.sharedModelContainer.mainContext
    private let aiProxyClient: AIProxyClient = AIProxyClient.shared
    private let settingsStore: SettingsStore = SettingsStore.shared

    init() {
        setupHotKey()
    }

    func showInputAssistant() {
        let clipboard = ClipboardService.getString() ?? ""
        let selection = InputsService.getInputSelection() ?? ""
        InlinePopupWindow.shared.present(
            inputText: selection.isEmpty && !SystemService.shared.accessGranted ? clipboard : selection,
            onExecute: self.updateSourceInput,
            onCancel: {InputsService.setInputFocus()})
    }

    func focusInputAssistant() {
        InlinePopupWindow.shared.focus();
    }

    private func setupHotKey() {
        KeyboardShortcuts.removeAllHandlers()
        KeyboardShortcuts.onKeyUp(for: .showInputAssistant) {
            if (InlinePopupWindow.shared.isVisible && NSApp.isActive) {
                InputsService.setInputFocus();
                InlinePopupWindow.shared.close();
            } else if (InlinePopupWindow.shared.isVisible && !NSApp.isActive) {
                self.focusInputAssistant();
            } else {
                self.showInputAssistant();
            }
        }
    }

    func getPromptShortcut(command: String, excludeDefault: Bool = false) -> PromptShortcutItem? {
        let fetchDescriptor = FetchDescriptor<PromptShortcutItem>(
            predicate: #Predicate { $0.command == command && (!excludeDefault || $0.isEditable)},
            sortBy: [SortDescriptor(\.command)]
        )
        do {
            if let existingItem = try modelContext.fetch(fetchDescriptor).first {
                return existingItem
            }
        } catch {
            fatalError("Failed to fetch or create AIProviderConfigItem: \(error)")
        }
        return nil;
    }

    func calculatePromptShortcutModel(for command: String) -> PromptShortcutItem {
        var promptShortcut: PromptShortcutItem? = nil;
        let parts = command.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
        let cmdName = parts.first.map(String.init) ?? ""

        if StaticCommandsService.exists(command: command) {
            return PromptShortcutItem(
                isEditable: false,
                command: command,
                model: "static",
                prompt: "",
            )
        }
        promptShortcut = self.getPromptShortcut(command: cmdName, excludeDefault: true);
        if (promptShortcut != nil) {
            return promptShortcut!
        }
        promptShortcut = self.getPromptShortcut(command: DEFAULT_PROMPT_COMMAND_KEY);
        if (promptShortcut != nil) {
            return promptShortcut!
        }
        return FALLBACK_PROMPT_SHORTCUT
    }

    func handleCommand(command: String, editableInputTextCanvas: Binding<String>) async throws -> String {
        let output = editableInputTextCanvas
        var promptShortcut: PromptShortcutItem? = nil;
        var commandText: String = command;
        let parts = command.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
        let cmdName = parts.first.map(String.init) ?? ""
        let rest = parts.count > 1 ? String(parts[1]) : ""

        if StaticCommandsService.exists(command: command) {
            editableInputTextCanvas.wrappedValue = StaticCommandsService.execute(command: command, input: editableInputTextCanvas.wrappedValue)
            return editableInputTextCanvas.wrappedValue
        }
        if let customCommand = self.getPromptShortcut(command: cmdName, excludeDefault: true) {
            promptShortcut = customCommand
            commandText = rest
        }

        if (promptShortcut == nil) {
            promptShortcut = self.getPromptShortcut(command: DEFAULT_PROMPT_COMMAND_KEY);
        }

        if (promptShortcut == nil) {
            promptShortcut = FALLBACK_PROMPT_SHORTCUT;
        }

        var _ = try await aiProxyClient.askChoosenAI(text: editableInputTextCanvas, promptShortcut: promptShortcut!, command: commandText)
        return output.wrappedValue;
    }
    
    func updateSourceInput(_ output: String) {
        guard !output.isEmpty else {
            InputsService.setInputFocus()
            return
        }
        if (systemService.accessGranted && InputsService.lastAppPID != 0) {
            InputsService.setInputSelection(output)
        } else {
            ClipboardService.setString(output)
        }
        
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
