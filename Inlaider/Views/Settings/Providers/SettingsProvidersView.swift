import SwiftUI

struct SettingsProvidersView: View {
    @ObservedObject private var settingsStore: SettingsStore = SettingsStore.shared
    @ObservedObject private var aiProxyClient: AIProxyClient = AIProxyClient.shared
    var providersConfigs: [AIProviderConfigItem] = []
    var providersModels: [AIProviderConfigModelItem] = []
    
    private func getProviderObject(_ providerName: String) -> AIProviderProtocol? {
        return aiProxyClient.providers.first(where: { $0.name == providerName && !$0.hidden })
    }
    
    var body: some View {
        VStack(spacing: 8){
            TabView(selection: $settingsStore.settingsWindowProvidersSelectedTab) {
                ForEach(providersConfigs, id: \.name) { providerConfig in
                    if let provider = getProviderObject(providerConfig.name) {
                        VStack(alignment: .leading, spacing: 16) {
                            SettingsProviderConfigView(
                                provider: provider,
                                providerConfig: providerConfig,
                                providersModels: providersModels
                            )
                        }
                        .padding(8)
                        .tabItem {
                            Label(
                                providerConfig.name,
                                systemImage: provider.symbol,
                            )
                        }
                        .tag(providerConfig.name)
                    }
                }
            }
            .tabViewStyle(.grouped)
        }.padding(32)
        
    }
}


#Preview {
    SettingsWindow()
        .modelContainer(InlaiderApp.sharedModelContainer)
        .onAppear {
            SettingsStore.shared.settingsWindowSelectedTab = .providers
        }
}

