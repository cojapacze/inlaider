import Foundation
import SwiftData

@Model
final class AIProviderConfigModelItem {
    var providerName: String
    var modelName: String

    init(providerName: String, modelName: String) {
        self.providerName = providerName
        self.modelName = modelName
    }
}
