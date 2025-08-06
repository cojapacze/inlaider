import SwiftUI
import AIProxy
import SwiftData

class AnthropicProvider: AIProviderProtocol {
    var hidden: Bool {
        return REGION == CHINA_BLOCK_ID
    }
    var isDefault = false
    var configItem: AIProviderConfigItem
    let platformUrl = URL(string: "https://www.anthropic.com/api")!
    let name = "Anthropic"
    let symbol = "person.2"
    let defaultModels = ["claude-3-5-sonnet-20240620"]

    init(modelContext: ModelContext) {
        self.configItem = prepareProviderConfigItem(modelContext: modelContext, name: self.name, defaultModels: self.defaultModels)
    }

    private func getMessage(text: String, type: CompletionRequestMessageRoleType?) -> AnthropicInputMessage {
        switch type {
        case .user:
            return AnthropicInputMessage(
                content: [.text(text)],
                role: .user
            )
        case .assistant:
            return AnthropicInputMessage(
                content: [.text(text)],
                role: .assistant
            )
        default:
            return AnthropicInputMessage(
                content: [.text(text)],
                role: .assistant
            )
        }
    }

    func askAI(generalPrompt: String, prompt: String, text: Binding<String>, userPrompt: String, model: String) async throws -> String {
        var response: String = ""
        let anthropicAIService = AIProxy.anthropicDirectService(
            unprotectedAPIKey: try getApiKey(provider: self)
        )
        let validMessages = prepareMessages(generalPrompt: generalPrompt, prompt: prompt, text: text.wrappedValue, userPrompt: userPrompt, model: model)
        let messages = validMessages.map { validMessage in getMessage(text: validMessage.text, type: validMessage.role)}
        let requestBody = AnthropicMessageRequestBody(
            maxTokens: 1024,
            messages: messages,
            model: model
        )
        let stream = try await anthropicAIService.streamingMessageRequest(body: requestBody)
        text.wrappedValue = "";
        for try await chunk in stream {
            switch chunk {
            case .text(let part):
                response += part
                text.wrappedValue = response
            case .toolUse(name: let toolName, input: let toolInput):
                print("Claude wants to call tool \(toolName) with input \(toolInput)")
            }
        }
        return response
    }
}
