//
//  InlaiderApp.swift
//  Inlaider
//
//  Created by Krzysztof on 27/06/2025.
//

import SwiftUI
import SwiftData

@main
struct InlaiderApp: App {
    static let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            AIProviderConfigItem.self,
            AIProviderConfigModelItem.self,
            PromptShortcutItem.self,
            CommandHistoryItem.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true )
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        MenuBarExtraInlaider()
        Settings {
            SettingsWindow()
        }
        .modelContainer(InlaiderApp.sharedModelContainer)
    }
}
