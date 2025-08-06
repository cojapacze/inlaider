import SwiftUI
import SwiftData

enum CompletionRequestMessageRoleType: String {
    case system
    case user
    case assistant
    case developer
}
struct CompletionRequestMessage {
    let text: String
    let role: CompletionRequestMessageRoleType
}

protocol AIProviderProtocol: AnyObject {
    var name: String { get }
    var symbol: String { get }
    var defaultModels: [String] { get }
    var platformUrl: URL { get }
    var configItem: AIProviderConfigItem { get set }
    var isDefault: Bool { get }
    var hidden: Bool { get }
    func askAI(
        generalPrompt: String,
        prompt: String,
        text: Binding<String>,
        userPrompt: String,
        model: String
    ) async throws -> String
    
}

func getProviderConfigModelItem(
    modelContext: ModelContext,
    providerName: String,
    modelName: String
) -> AIProviderConfigModelItem? {
    let fetchDescriptor = FetchDescriptor<AIProviderConfigModelItem>(
        predicate: #Predicate { $0.modelName == modelName && $0.providerName == providerName},
        sortBy: [SortDescriptor(\.modelName)]
    )

    do {
        if let existingItem = try modelContext.fetch(fetchDescriptor).first {
            return existingItem
        }
    } catch {
        fatalError("Failed to fetch or create AIProviderConfigItem: \(error)")
    }
    return nil
}
func getProviderConfigItem(
    modelContext: ModelContext,
    name: String
) -> AIProviderConfigItem? {
    let fetchDescriptor = FetchDescriptor<AIProviderConfigItem>(
        predicate: #Predicate { $0.name == name },
        sortBy: [SortDescriptor(\.name)]
    )
    do {
        if let existingItem = try modelContext.fetch(fetchDescriptor).first {
            return existingItem
        }
    } catch {
        fatalError("Failed to fetch or create AIProviderConfigItem: \(error)")
    }
    return nil
}

func prepareProviderConfigItem(modelContext: ModelContext, name: String, defaultModels: [String]) -> AIProviderConfigItem {
    do {
        var providerItem = getProviderConfigItem(modelContext: modelContext, name: name)
        if (providerItem == nil) {
            providerItem = AIProviderConfigItem(name: name, apiKey: "")
            modelContext.insert(providerItem!)
            try modelContext.save()
        }
        for modelName in defaultModels {
            var providerModel = getProviderConfigModelItem(modelContext: modelContext, providerName: name, modelName: modelName)
            if (providerModel == nil) {
                providerModel = AIProviderConfigModelItem(providerName: name, modelName: modelName)
                modelContext.insert(providerModel!)
                try modelContext.save()
            }
        }
        return providerItem!
    } catch {
        fatalError("Failed to fetch or create AIProviderConfigItem: \(error)")
    }
}

func getApiKey(provider: AIProviderProtocol) throws -> String {
    let apiKey = provider.configItem.apiKey
    if (apiKey.isEmpty) {
        throw NSError(domain: provider.name, code: 1001, userInfo: [NSLocalizedDescriptionKey : "Please enter your \(provider.name) API Key", "apiProvider": provider.name, "openSettings": true])
    }
    return apiKey
}

func prepareMessages(generalPrompt: String, prompt: String, text: String, userPrompt: String, model: String) -> [CompletionRequestMessage] {
    var result: [CompletionRequestMessage] = []
    if (!generalPrompt.isEmpty) {
        result.append(.init(text: generalPrompt, role: .system))
    }
    if (!prompt.isEmpty) {
        result.append(.init(text: prompt, role: .system))
    }
    if (!text.isEmpty) {
        result.append(.init(text: text, role: .user))
    }
    if (!userPrompt.isEmpty) {
        result.append(.init(text: userPrompt, role: text.isEmpty ? .user : .system))
    }
    return result;
}

