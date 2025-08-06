import SwiftUI
import SwiftData

enum SettingsTab: Hashable  {
    case general, providers, prompts, info
}

struct SettingsWindow: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject private var settingsStore: SettingsStore = SettingsStore.shared
    
    @Query private var providersConfigs: [AIProviderConfigItem] = []
    @Query(sort: [
        SortDescriptor(\AIProviderConfigModelItem.providerName, order: .forward),
        SortDescriptor(\AIProviderConfigModelItem.modelName, order: .forward),
    ]) private var providersModels: [AIProviderConfigModelItem] = []
    @Query(sort: [
        SortDescriptor(\PromptShortcutItem.isEditable, order: .forward),
        SortDescriptor(\PromptShortcutItem.command, order: .forward)
    ]) private var promptShortcuts: [PromptShortcutItem] = []
    
    var body: some View {
        TabView(selection: $settingsStore.settingsWindowSelectedTab) {
            SettingsGeneralView(
            )
            .tabItem {
                Label(NSLocalizedString("settings.section.general.title", comment: "Settings general tab title"), systemImage: "gearshape")
            }
            .tag(SettingsTab.general)

            SettingsProvidersView(
                providersConfigs: providersConfigs,
                providersModels: providersModels,
            )
            .tabItem {
                Label(NSLocalizedString("settings.section.ownAPIKeys.title", comment: "Providers settings tab title"), systemImage: "questionmark.key.filled")
            }
            .tag(SettingsTab.providers)
            
            SettingsPromptsView(
                providersConfigs: providersConfigs,
                providersModels: providersModels,
                promptShortcuts: promptShortcuts,
            )
            .tabItem {
                Label(NSLocalizedString("settings.section.customPrompts.title", comment: "Prompts settings tab title"), systemImage: "list.triangle")
            }
            .tag(SettingsTab.prompts)
        }
        .padding(8)
        .frame(width: 720, height: 480)
    }
}

#Preview {
    SettingsWindow()
}
