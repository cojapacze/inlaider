import AIProxy
import SwiftUI
import Combine
import SwiftData

enum AIProxyClientStatus: String {
    case idle
    case working
}

@MainActor
class AIProxyClient: ObservableObject {
    static let shared = AIProxyClient()
    @Published var status: AIProxyClientStatus = .idle
    @Published var providers: [any AIProviderProtocol] = []
    private let modelContext: ModelContext = InlaiderApp.sharedModelContainer.mainContext
    private let settingsStore: SettingsStore = .shared

    init() {
        AIProxy.configure(
            logLevel: .info,
            printRequestBodies: false,  // Flip to true for library development
            printResponseBodies: false, // Flip to true for library development
            resolveDNSOverTLS: true,
            useStableID: true,         // Please see the docstring if you'd like to enable this
        )

        // init all AI Providers
        providers.append(OpenAIProvider(modelContext: modelContext))
        providers.append(AnthropicProvider(modelContext: modelContext))
        providers.append(DeepSeekProvider(modelContext: modelContext))
        providers.append(GeminiProvider(modelContext: modelContext))
        providers.append(MistralProvider(modelContext: modelContext))
        providers.append(PerplexityProvider(modelContext: modelContext))
    }

    func getBestProvider(_ suggestedProvider: String) -> any AIProviderProtocol {
        var bestProvider: (any AIProviderProtocol)? = providers.first(where: { $0.name == suggestedProvider })
        if (bestProvider == nil) {
            bestProvider = providers.first(where: { $0.isDefault })
        }
        if (bestProvider == nil) {
            bestProvider = providers.first
        }
        return bestProvider!
    }

    func askChoosenAI(text: Binding<String>, promptShortcut: PromptShortcutItem, command: String) async throws -> String {
        let generalPrompt = settingsStore.generalPrompt
        self.status = .working
        defer {
            self.status = .idle
        }
        print("General prompt: [\(generalPrompt)]")
        print("Shortcut model: [\(promptShortcut.model)]")
        print("Shortcut prompt: [\(promptShortcut.prompt)]")
        let provider = self.getBestProvider(promptShortcut.providerName)
        print("Selected provider: [\(provider.name)]")
        print("Provider name: [\(promptShortcut.providerName)]")
        print("Provider model: [\(promptShortcut.modelName)]")
        print("Input text: [\(text.wrappedValue)]")
        print("User prompt: [\(command)]")
        return try await provider.askAI(
            generalPrompt: generalPrompt,
            prompt: promptShortcut.prompt,
            text: text,
            userPrompt: command,
            model: promptShortcut.modelName
        )
    }
}
