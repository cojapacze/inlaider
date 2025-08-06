import Foundation
import SwiftData

@Model
final class AIProviderConfigItem {
    @Attribute(.unique) var name: String
    var apiKey: String

    init(
        name: String,
        apiKey: String
    ) {
        self.name = name
        self.apiKey = apiKey
    }
}
