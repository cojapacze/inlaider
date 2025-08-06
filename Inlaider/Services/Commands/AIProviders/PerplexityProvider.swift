import SwiftUI
import AIProxy
import SwiftData

class PerplexityProvider: AIProviderProtocol {
    var hidden: Bool {
        return REGION == CHINA_BLOCK_ID
    }
    var isDefault = false
    var configItem: AIProviderConfigItem
    let platformUrl = URL(string: "https://www.perplexity.ai/")!
    let name = "Perplexity"
    let symbol = "questionmark.circle"
    let defaultModels = ["llama-3.1-sonar-small-128k-online"]

    init(modelContext: ModelContext) {
        self.configItem = prepareProviderConfigItem(modelContext: modelContext, name: self.name, defaultModels: self.defaultModels)
    }

    private func getMessage(text: String, type: CompletionRequestMessageRoleType?) -> PerplexityChatCompletionRequestBody.Message {
        switch type {
        case .user:
            return PerplexityChatCompletionRequestBody.Message.user(content: text)
        case .assistant:
            return PerplexityChatCompletionRequestBody.Message.assistant(content: text)
        default:
            return PerplexityChatCompletionRequestBody.Message.system(content: text)
        }
    }

    func askAI(generalPrompt: String, prompt: String, text: Binding<String>, userPrompt: String, model: String) async throws -> String {
        var response: String = ""
        let perplexityAIService = AIProxy.perplexityDirectService(
            unprotectedAPIKey: try getApiKey(provider: self)
        )
        let validMessages = prepareMessages(generalPrompt: generalPrompt, prompt: prompt, text: text.wrappedValue, userPrompt: userPrompt, model: model)

        var messages: [PerplexityChatCompletionRequestBody.Message] = []
        var firstUserMessage = false;
        for validMessage in validMessages {
            if (validMessage.role == .assistant) {
                if (!firstUserMessage) {
                    messages.append(getMessage(text: "", type: .user))
                    firstUserMessage = true
                }
            }
            if (validMessage.role == .user) {
                firstUserMessage = true;
            }
            messages.append(getMessage(text: validMessage.text, type: validMessage.role))
        }

        let stream = try await perplexityAIService.streamingChatCompletionRequest(body: .init(
            messages: messages,
            model: model
        ))
        text.wrappedValue = "";
        for try await chunk in stream {
            let part = chunk.choices.first?.delta?.content ?? "";
            response += part
            text.wrappedValue = response
        }
        return response;
    }
}
