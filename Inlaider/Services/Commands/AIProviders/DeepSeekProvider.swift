import SwiftUI
import AIProxy
import SwiftData

class DeepSeekProvider: AIProviderProtocol {
    var hidden: Bool {
        return false
    }
    var isDefault = false
    var configItem: AIProviderConfigItem
    let platformUrl = URL(string: "https://platform.deepseek.com/")!
    let name = "DeepSeek"
    let symbol = "magnifyingglass"
    let defaultModels = ["deepseek-chat"]
    
    init(modelContext: ModelContext) {
        self.configItem = prepareProviderConfigItem(modelContext: modelContext, name: self.name, defaultModels: self.defaultModels)
    }

    private func getMessage(text: String, type: CompletionRequestMessageRoleType?) -> DeepSeekChatCompletionRequestBody.Message {
        switch type {
        case .user:
            return DeepSeekChatCompletionRequestBody.Message.user(content: text)
        case .assistant:
            return DeepSeekChatCompletionRequestBody.Message.assistant(content: text)
        default:
            return DeepSeekChatCompletionRequestBody.Message.system(content: text)
        }
    }

    func askAI(generalPrompt: String, prompt: String, text: Binding<String>, userPrompt: String, model: String) async throws -> String {
        var response: String = ""
        let deepSeekAIService = AIProxy.deepSeekDirectService(
            unprotectedAPIKey: try getApiKey(provider: self)
        )
        let validMessages = prepareMessages(generalPrompt: generalPrompt, prompt: prompt, text: text.wrappedValue, userPrompt: userPrompt, model: model)
        let messages = validMessages.map { validMessage in getMessage(text: validMessage.text, type: validMessage.role)}

        let requestBody = DeepSeekChatCompletionRequestBody(
            messages: messages,
            model: model
        )
        let stream = try await deepSeekAIService.streamingChatCompletionRequest(body: requestBody)
        text.wrappedValue = "";
        for try await part in stream {
            let chunk = part.choices.first?.delta.content ?? "";
            response += chunk
            text.wrappedValue = response
        }
        return response;
    }
}

