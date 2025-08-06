import SwiftUI
import SwiftData

@MainActor
final class SettingsStore: ObservableObject {
    static let shared = SettingsStore()
    private let modelContext: ModelContext = InlaiderApp.sharedModelContainer.mainContext;

    @Published var settingsWindowSelectedTab: SettingsTab = .general
    @Published var settingsWindowProvidersSelectedTab: String = ""
    @Published var generalPrompt: String {
        didSet {
            UserDefaults.standard.set(generalPrompt, forKey: "generalPrompt")
        }
    }

    init() {
        self.generalPrompt = UserDefaults.standard.string(forKey: "generalPrompt") ?? DEFAULT_GENERAL_PROMPT
        let fetchDescriptor = FetchDescriptor<PromptShortcutItem>(
            predicate: #Predicate { $0.command == DEFAULT_PROMPT_COMMAND_KEY },
            sortBy: [SortDescriptor(\.command)]
        )
        do {
            if let _ = try modelContext.fetch(fetchDescriptor).first {
            } else {
                for easyPromptShortcut in DEFAULT_PROMPTS {
                    modelContext.insert(easyPromptShortcut)
                }
                try modelContext.save()
            }
        } catch {
            fatalError("Failed to fetch or create AIProviderConfigItem: \(error)")
        }
    }
}

