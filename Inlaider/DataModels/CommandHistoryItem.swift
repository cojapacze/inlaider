import Foundation
import SwiftData

@Model
final class CommandHistoryItem {
    var command: String
    var timestamp: Date

    init(command: String, timestamp: Date = .now) {
        self.command = command
        self.timestamp = timestamp
    }
}
