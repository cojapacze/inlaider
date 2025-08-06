import SwiftUI

extension Bool: @retroactive Comparable {
    public static func <(lhs: Self, rhs: Self) -> Bool {
        // the only true inequality is false < true
        !lhs && rhs
    }
}

struct PromptShortcutItemWrapper: Identifiable {
    let id: UUID
    let promptShortcut: PromptShortcutItem
    init (_ promptShortcut: PromptShortcutItem) {
        self.id = UUID(uuidString: promptShortcut.id.uuidString)!
        self.promptShortcut = promptShortcut
    }
}

struct PromptShortcutsTable: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var selection: Set<PromptShortcutItemWrapper.ID> = []
    @State private var editingPromptShortcut: PromptShortcutItem?
    @State private var newPromptShortcut: PromptShortcutItem?
    var providersModels: [AIProviderConfigModelItem] = []
    var promptShortcuts: [PromptShortcutItem] = []
    
    private func getWrappedPromptShortcuts() -> [PromptShortcutItemWrapper] {
        let identifiedPrompts = promptShortcuts.map {
            PromptShortcutItemWrapper($0)
        }
        return identifiedPrompts;
    }

    private func allProviderModelStrings() -> [String] {
//        print("!!!allProviderModelStrings")
//        var defaultProvider: AIProviderProtocol?;
        var allModels : [String] = providersModels.map {
            let modelProvider = AIProxyClient.shared.getBestProvider($0.providerName)
            if (modelProvider.hidden) {
                return nil
            }
            if modelProvider.isDefault {
//                defaultProvider = modelProvider
                return nil
            }
            return "\($0.providerName)/\($0.modelName)"
        }
            .filter { $0 != nil }.compactMap(\.self).sorted();
//        print("Default provider", defaultProvider?.name ?? "No default")
        //allModels
        allModels.insert(DEFAULT_PROVIDER_MODEL_NAME, at: 0)
        
        // to mi dublowalo, ale bylo pierwsze:
//        if defaultProvider != nil {
////            let name = defaultProvider.name!
//            allModels.insert(DEFAULT_PROVIDER_MODEL_NAME, at: 0)
//        } else {
//            // why defaultProvider is not on allModels list?
//            allModels.insert(DEFAULT_PROVIDER_MODEL_NAME, at: 0)
//        }
//        AIProviderProtocol
//        print("allModels", allModels)

//        return ["s"]
        return allModels;
    }

    private func handleTap(on item: PromptShortcutItemWrapper) {
        if selection.contains(item.id) {
            editingPromptShortcut = item.promptShortcut
        }
        selection = [item.id]
    }
    
    private var hasDeletableSelection: Bool {
        return promptShortcuts.contains { item in
            selection.contains(item.id) && item.isEditable
        }
    }

    private func addRow() {
        self.newPromptShortcut = PromptShortcutItem(
            command: "",
            model: allProviderModelStrings().first ?? "",
            prompt: ""
        )
    }
    
    private func deleteRows() {
        for id in selection {
            let promptShortcut = promptShortcuts.first(where: { $0.id == id && $0.isEditable})
            if (promptShortcut != nil) {
                modelContext.delete(promptShortcut!)
            }
        }
        Task {
            try modelContext.save()
        }
        selection = selection.filter { id in
            promptShortcuts.contains { $0.id == id }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Table(getWrappedPromptShortcuts(), selection: $selection) {
                TableColumn(NSLocalizedString("prompts.replacements.replaceWhat.label", comment: "Replace shortcut label")) { item in
                    HStack {
                        Text(item.promptShortcut.command).foregroundStyle(item.promptShortcut.isEditable ? .primary :.secondary)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        handleTap(on: item)
                    }
                }
                TableColumn(NSLocalizedString("prompts.replacements.model.label", comment: "Shortcut model label")) { item in
                    HStack {
                        Text(item.promptShortcut.model)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        handleTap(on: item)
                    }
                }
                TableColumn(NSLocalizedString("prompts.replacements.replaceWith.label", comment: "Shortcut prompt label")) { item in
                    HStack {
                        Text(item.promptShortcut.prompt).lineLimit(1)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        handleTap(on: item)
                    }
                }
            }
            .selectionDisabled(true)
            .cornerRadius(UI_INPUT_RADIUS)
            .frame(minHeight: 220)
            .overlay(
                RoundedRectangle(cornerRadius: UI_INPUT_RADIUS)
                    .stroke(UI_INPUT_BORDER_COLOR)
            )
            
            HStack {
                Button { addRow() }             label: { Image(systemName: "plus") }
                Button { deleteRows() }         label: { Image(systemName: "minus") }
                    .disabled(!hasDeletableSelection)
                Spacer()
            }
            .padding(.vertical, 12)
        }
        .sheet(item: $editingPromptShortcut) { psc in
            EditPromptShortcutForm(
                promptShortcut: PromptShortcutItem(
                    isEditable: psc.isEditable,
                    command: psc.command,
                    model: psc.model,
                    prompt: psc.prompt
                ),
                allProviderModels: allProviderModelStrings(),
                promptShortcuts: promptShortcuts
            ) {
                result in
                editingPromptShortcut?.command = result.command
                editingPromptShortcut?.model = result.model
                editingPromptShortcut?.prompt = result.prompt
                Task {
                    try modelContext.save()
                }
            }
        }
        .sheet(item: $newPromptShortcut) { npsc in
            EditPromptShortcutForm(
                promptShortcut: npsc,
                allProviderModels: allProviderModelStrings(),
                promptShortcuts: promptShortcuts
            ) {
                result in
                Task {
                    modelContext.insert(result)
                    try modelContext.save()
                }
            }
        }
    }
}

#Preview {
    SettingsWindow()
        .modelContainer(InlaiderApp.sharedModelContainer)
        .onAppear {
            SettingsStore.shared.settingsWindowSelectedTab = .prompts
        }
}
