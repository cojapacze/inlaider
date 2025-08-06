protocol StaticCommandProtocol {
    var command: String { get }
    func execute(input: String) -> String
}

struct StaticCommandUppercase: StaticCommandProtocol {
    let command: String = ".uppercase"
    func execute(input: String) -> String {
        return input.uppercased()
    }
}

struct StaticCommandLowercase: StaticCommandProtocol {
    let command: String = ".lowercase"
    func execute(input: String) -> String {
        return input.lowercased()
    }
}

struct StaticCommandCapitalize: StaticCommandProtocol {
    let command: String = ".capitalize"
    func execute(input: String) -> String {
        return input.capitalized
    }
}

struct StaticCommandReverse: StaticCommandProtocol {
    let command: String = ".reverse"
    func execute(input: String) -> String {
        var lines = input.components(separatedBy: .newlines)
        lines.reverse()
        return lines.joined(separator: "\n")
    }
}

struct StaticCommandSort: StaticCommandProtocol {
    let command: String = ".sort"
    func execute(input: String) -> String {
        var lines = input.components(separatedBy: .newlines)
        lines.sort()
        return lines.joined(separator: "\n")
    }
}

struct StaticCommandTrim: StaticCommandProtocol {
    let command: String = ".trim"
    func execute(input: String) -> String {
        let lines = input.components(separatedBy: .newlines)
        let trimmedLines = lines.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        return trimmedLines.joined(separator: "\n")
    }
}

struct StaticCommandUnique: StaticCommandProtocol {
    let command: String = ".unique"
    func execute(input: String) -> String {
        let lines = input.components(separatedBy: .newlines)//co to jest?
        var seen = Set<String>()
        let uniqueLines = lines.filter { line in
            if seen.contains(line) {
                return false
            } else {
                seen.insert(line)
                return true
            }
        }
        return uniqueLines.joined(separator: "\n")
    }
}

struct StaticCommandRemoveEmptyLines: StaticCommandProtocol {
    let command: String = ".removeEmptyLines"
    func execute(input: String) -> String {
        let lines = input.components(separatedBy: .newlines)
        let nonEmptyLines = lines.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        return nonEmptyLines.joined(separator: "\n")
    }
}

class StaticCommandsService {
    static let commands: [StaticCommandProtocol] = [
        StaticCommandUppercase(),
        StaticCommandLowercase(),
        StaticCommandCapitalize(),
        StaticCommandReverse(),
        StaticCommandSort(),
        StaticCommandTrim(),
        StaticCommandUnique(),
        StaticCommandRemoveEmptyLines(),
    ]
    static func exists(command: String) -> Bool {
        return commands.contains(where: { $0.command == command })
    }
    static func getAllCommands() -> [String] {
        return commands.map(\.command)
    }
    static func execute(command: String, input: String) -> String {
        guard let commandProtocol = commands.first(where: { $0.command == command }) else {
            print("Command not found: \(command)")
            return input
        }
        return commandProtocol.execute(input: input)
    }
}

