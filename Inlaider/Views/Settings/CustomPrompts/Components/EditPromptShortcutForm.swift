import SwiftUI

struct EditPromptShortcutForm: View {
    @Environment(\.dismiss) private var dismiss
    @State private var localPromptShortcut: PromptShortcutItem
    @State private var sourceCommand: String?
    @State var allProviderModels: [String] = []
    var promptShortcuts: [PromptShortcutItem] = []

    private let onSave: (_ result: PromptShortcutItem) -> Void

    private func promptCommandExists(_ command: String) -> Bool {
        promptShortcuts.contains { $0.command == command }
    }

    init(
        promptShortcut: PromptShortcutItem,
        allProviderModels: [String],
        promptShortcuts: [PromptShortcutItem],
        onSave: @escaping (_ result: PromptShortcutItem) -> Void,
    ) {
        _localPromptShortcut = State(initialValue: promptShortcut)
        _sourceCommand = State(initialValue: promptShortcut.command)
        self.allProviderModels = allProviderModels
        self.promptShortcuts = promptShortcuts
        self.onSave = onSave
    }

    var body: some View {
        Form {
            TextField(NSLocalizedString("prompts.replacements.replaceWhat.label", comment: "Replace shortcut label"), text: $localPromptShortcut.command)
                .textFieldStyle(.roundedBorder)
                .disabled(!localPromptShortcut.isEditable)
            Picker(NSLocalizedString("prompts.replacements.model.label", comment: "Shortcut model label"), selection: $localPromptShortcut.model) {
                if !allProviderModels.contains(localPromptShortcut.model) {
                    Text(localPromptShortcut.model).tag(localPromptShortcut.model)
                }
                ForEach(allProviderModels, id: \.self) {
                    
//                    if ($0)
                    Text($0).tag($0)
                }
            }
            LabeledContent(NSLocalizedString("prompts.replacements.replaceWith.label", comment: "Shortcut prompt label")) {
                TextEditor(text: $localPromptShortcut.prompt)
                    .font(.system(size: UI_INPUT_FONT_SIZE))
                    .frame(minHeight: 60, maxHeight: 240)
                //                    .accessibilityLabel(Text(label))
                    .textEditorStyle(.plain)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: UI_INPUT_RADIUS)
                            .fill(UI_INPUT_BACKGROUND_COLOR)
                            .stroke(UI_INPUT_BORDER_COLOR)
                    )
            }
        }
        .padding()
        .frame(width: 360)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(NSLocalizedString("cancel", comment: "Cancel button label")) { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(NSLocalizedString("save", comment: "Cancel button label")) {
                    Task {
                        do {
                            let message = String(format: NSLocalizedString("prompts.replacements.error.exists.message", comment: "Error when a shortcut command is duplicated"), self.localPromptShortcut.command)
                            if (sourceCommand != self.localPromptShortcut.command && promptCommandExists(self.localPromptShortcut.command)) {
                                throw NSError(domain: "prompt-shortcuts", code: 1002, userInfo: [NSLocalizedDescriptionKey : message])
                            }
                            onSave(self.localPromptShortcut)
                            dismiss()
                        } catch {
                            showErrorAlert(error: error)
                        }
                    }
                }
                .keyboardShortcut(.defaultAction)
            }
        }
    }
}

#Preview {
    let promptShortcut = PromptShortcutItem(
        command: "command",
        model: "NonExistsProvider/NotExistsModel",
        prompt: "prompt"
    )
    EditPromptShortcutForm(
        promptShortcut: promptShortcut,
        allProviderModels: [DEFAULT_PROVIDER_MODEL_NAME, "#AbyProvider/AnyModel"],
        promptShortcuts: DEFAULT_PROMPTS
    ) {
        result in
            print("-- result --")
            print("Command:", result.command)
            print("Model:", result.model)
            print("Prompt:", result.prompt)
            print("Editable:", result.isEditable)
    }
}
