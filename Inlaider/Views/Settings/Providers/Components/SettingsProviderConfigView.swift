import SwiftUI
import SwiftData

struct SettingsProviderConfigView: View {
    @Environment(\.modelContext) var modelContext
    @State var provider: AIProviderProtocol
    var providerConfig: AIProviderConfigItem
    var providersModels: [AIProviderConfigModelItem] = []
    @State var models: [String] = []
    @FocusState private var isAPIKeyFocused: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 4){
            HStack(spacing: 8) {
                Text(NSLocalizedString("provider.apiKey.title", comment: "Provider config API key label"))
                    .font(.headline)
                SecureField(NSLocalizedString("provider.apiKey.placeholder", comment: "Provider config API key placeholder"), text: Binding<String>(
                    get: { providerConfig.apiKey },
                    set: { newApiKey in
                        providerConfig.apiKey = newApiKey.trimmingCharacters(in: .whitespacesAndNewlines) }
                ))
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: .infinity)
                .focused($isAPIKeyFocused)
            }
            Spacer()
            Link(provider.platformUrl.absoluteString, destination: provider.platformUrl)
            Spacer()
            VStack(alignment: .leading, spacing: 8) {
                Text(NSLocalizedString("provider.models.title", comment: "Provider config models list label"))
                    .font(.headline)
                EditableStringListView(items: $models)
            }
        }.padding(16)
            .onAppear {
                models = providersModels.filter { $0.providerName == providerConfig.name}.map { $0.modelName }
                if (providerConfig.apiKey == "") {
                    isAPIKeyFocused = true
                }
            }
            .onDisappear {
                providersModels.forEach { providerModel in
                    if (providerModel.providerName == providerConfig.name) {
                        modelContext.delete(providerModel)
                    }
                }
                Array(Set(models)).forEach {
                    newModelName in
                    modelContext.insert(AIProviderConfigModelItem(providerName: providerConfig.name, modelName: newModelName))
                }
            }
    }
}

#Preview {
    SettingsWindow()
        .modelContainer(InlaiderApp.sharedModelContainer)
        .onAppear {
            SettingsStore.shared.settingsWindowSelectedTab = .providers
        }
}
