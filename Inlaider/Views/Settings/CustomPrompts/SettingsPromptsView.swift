import SwiftUI

struct SettingsPromptsView: View {
    @StateObject var settingsStore: SettingsStore = .shared
    @Environment(\.undoManager) private var undoManager
    var providersConfigs: [AIProviderConfigItem] = []
    var providersModels: [AIProviderConfigModelItem] = []
    var promptShortcuts: [PromptShortcutItem] = []

    var body: some View {
        VStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                let label = NSLocalizedString("prompts.general.title", comment: "General prompt input label");
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextEditor(text: $settingsStore.generalPrompt)
                    .frame(height: 100)
                    .font(.system(size: UI_INPUT_FONT_SIZE))
                    .accessibilityLabel(Text(label))
                    .textEditorStyle(.plain)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: UI_INPUT_RADIUS)
                            .fill(UI_INPUT_BACKGROUND_COLOR)
                            .stroke(UI_INPUT_BORDER_COLOR)
                    )
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(NSLocalizedString("prompts.replacements.title", comment: "Prompts shortcuts table label"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                PromptShortcutsTable(
                    providersModels: providersModels,
                    promptShortcuts: promptShortcuts,
                )
            }
        }.padding(16).onAppear() {
            //crash fix
            undoManager?.removeAllActions()
        }
    }
}

#Preview {
    SettingsWindow()
        .modelContainer(InlaiderApp.sharedModelContainer)
        .onAppear {
            SettingsStore.shared.settingsWindowSelectedTab = .prompts
        }
}
