import SwiftUI
import AIProxy
import SwiftData

class MistralProvider: AIProviderProtocol {
    var hidden: Bool {
        return REGION == CHINA_BLOCK_ID
    }
    var isDefault = false
    var configItem: AIProviderConfigItem
    let platformUrl = URL(string: "https://mistral.ai/")!
    let name = "Mistral"
    let symbol = "wind"
    let defaultModels = ["mistral-small-latest"]

    init(modelContext: ModelContext) {
        self.configItem = prepareProviderConfigItem(modelContext: modelContext, name: self.name, defaultModels: self.defaultModels)
    }

    private func getMessage(text: String, type: CompletionRequestMessageRoleType?) -> MistralChatCompletionRequestBody.Message {
        switch type {
        case .user:
            return MistralChatCompletionRequestBody.Message.user(content: text)
        case .assistant:
            return MistralChatCompletionRequestBody.Message.assistant(content: text)
        default:
            return MistralChatCompletionRequestBody.Message.system(content: text)
        }
    }

    func askAI(generalPrompt: String, prompt: String, text: Binding<String>, userPrompt: String, model: String) async throws -> String {
        var response: String = ""
        let mistralAIService = AIProxy.mistralDirectService(
            unprotectedAPIKey: try getApiKey(provider: self)
        )
        let validMessages = prepareMessages(generalPrompt: generalPrompt, prompt: prompt, text: text.wrappedValue, userPrompt: userPrompt, model: model)
        let messages = validMessages.map { validMessage in getMessage(text: validMessage.text, type: validMessage.role)}
        let requestBody = MistralChatCompletionRequestBody(
            messages: messages,
            model: model
        )
        let stream = try await mistralAIService.streamingChatCompletionRequest(
            body: requestBody,
            secondsToWait: 60
        )
        text.wrappedValue = "";
        for try await chunk in stream {
            let part = chunk.choices.first?.delta.content ?? "";
            response += part
            text.wrappedValue = response
        }
        return response
    }
}
