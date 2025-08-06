import Foundation
import SwiftData

@Model
final class PromptShortcutItem {
    var id: UUID = UUID();
    var isEditable: Bool = true
    var command: String
    var model: String
    var prompt: String

    init(
        id: UUID = UUID(),
        isEditable: Bool = true,
        command: String,
        model: String = DEFAULT_PROVIDER_MODEL_NAME,
        prompt: String,
    ) {
        self.id = id;
        self.isEditable = isEditable
        self.command = command
        self.model = model
        self.prompt = prompt
    }
    
    var providerName: String {
        model.split(separator: "/", maxSplits: 1)
             .first
             .map(String.init) ?? model
    }

    var modelName: String {
        let parts = model.split(separator: "/", maxSplits: 1)
        return parts.count == 2 ? String(parts[1]) : model
    }

}
