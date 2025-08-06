import SwiftUI
import AIProxy
import SwiftData

class GeminiProvider: AIProviderProtocol {
    var hidden: Bool {
        return REGION == CHINA_BLOCK_ID
    }
    var isDefault = false
    var configItem: AIProviderConfigItem
    let platformUrl = URL(string: "https://gemini.google.com/")!
    let name = "Gemini"
    let symbol = "sparkles"
    let defaultModels = ["gemini-2.0-flash"]

    init(modelContext: ModelContext) {
        self.configItem = prepareProviderConfigItem(modelContext: modelContext, name: self.name, defaultModels: self.defaultModels)
    }

    private func getMessage(text: String, type: CompletionRequestMessageRoleType?) -> GeminiGenerateContentRequestBody.Content.Part {
        switch type {
        default:
            return .text(text)
        }
    }

    func askAI(generalPrompt: String, prompt: String, text: Binding<String>, userPrompt: String, model: String) async throws -> String {
        var response: String = ""
        let geminiAIService = AIProxy.geminiDirectService(
            unprotectedAPIKey: try getApiKey(provider: self)
        )
        let validMessages = prepareMessages(generalPrompt: generalPrompt, prompt: prompt, text: text.wrappedValue, userPrompt: userPrompt, model: model)
        var contentsParts: [GeminiGenerateContentRequestBody.Content.Part] = []
        var systemInstructionParts: [GeminiGenerateContentRequestBody.Content.Part] = []

        for validMessage in validMessages {
            switch validMessage.role {
            case .user:
                contentsParts.append(getMessage(text: validMessage.text, type: validMessage.role))
                break;
            default:
                systemInstructionParts.append(getMessage(text: validMessage.text, type: validMessage.role))
            }
        }

        let body = GeminiGenerateContentRequestBody(
            contents: [.init(parts : contentsParts)],
            generationConfig: .init(maxOutputTokens: 1024),
            systemInstruction: systemInstructionParts.count > 0 ? .init(parts: systemInstructionParts) : nil,
        )

        let stream = try await geminiAIService.generateStreamingContentRequest(body: body, model: model, secondsToWait: 10)
        text.wrappedValue = ""
        for try await chunk in stream {
            for part in chunk.candidates?.first?.content?.parts ?? [] {
                if case .text(let part) = part {
                    response += part
                    text.wrappedValue = response
                }
            }
        }
        return response;
    }
}
