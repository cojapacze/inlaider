import SwiftUI
import AIProxy
import SwiftData

class OpenAIProvider: AIProviderProtocol {
    var hidden: Bool {
        return REGION == CHINA_BLOCK_ID
    }
    var isDefault = false
    var configItem: AIProviderConfigItem
    let platformUrl = URL(string: "https://openai.com/api/")!
    let name = "OpenAI"
    let symbol = "brain"
    let defaultModels = [
        "gpt-5",
        "gpt-5-mini",
        "gpt-5-nano",
        "gpt-5-chat-latest",
        "gpt-4.1",
        "gpt-4.1-mini",
        "gpt-4.1-nano",
        "gpt-4.5-preview",
        "gpt-4o",
        "gpt-4o-mini",
        "o1",
        "o4-mini",
        "o3-mini",
        "computer-use-preview"
    ]

    init(modelContext: ModelContext) {
        self.configItem = prepareProviderConfigItem(modelContext: modelContext, name: self.name, defaultModels: self.defaultModels)
    }

    private func getMessage(text: String, type: CompletionRequestMessageRoleType?) -> OpenAIChatCompletionRequestBody.Message {
        switch type {
        case .user:
            return OpenAIChatCompletionRequestBody.Message.user(content: .text(text))
        case .assistant:
            return OpenAIChatCompletionRequestBody.Message.assistant(content: .text(text))
        default:
            return OpenAIChatCompletionRequestBody.Message.system(content: .text(text))
        }
    }

    func askAI(generalPrompt: String, prompt: String, text: Binding<String>, userPrompt: String, model: String) async throws -> String {
        var response: String = ""
        let openAIService = AIProxy.openAIDirectService(
            unprotectedAPIKey: try getApiKey(provider: self)
        )
        let validMessages = prepareMessages(generalPrompt: generalPrompt, prompt: prompt, text: text.wrappedValue, userPrompt: userPrompt, model: model)
        let messages = validMessages.map { validMessage in getMessage(text: validMessage.text, type: validMessage.role)}
        let body = OpenAIChatCompletionRequestBody(
            model: model,
            messages: messages,
        )
        let stream = try await openAIService.streamingChatCompletionRequest(body: body, secondsToWait: AI_QUERY_SECONDS_TO_WAIT)
        text.wrappedValue = ""
        for try await chunk in stream {
            if let delta = chunk.choices.first?.delta.content {
                response += delta
                text.wrappedValue = response
            }
        }
        return response;
    }
}
