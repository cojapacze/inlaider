import SwiftUI
import SwiftData

struct InlinePopupView: View {
    private let commandHandler: CommandHandler = .shared
    private let aiProxyClient: AIProxyClient = .shared
    private let settingsStore : SettingsStore = .shared
    @StateObject private var systemService: SystemService = .shared
    @Environment(\.openSettings) private var openSettings
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<PromptShortcutItem> { $0.isEditable == true },
           sort: \PromptShortcutItem.command, order: .forward) var promptShortcuts: [PromptShortcutItem] = []
    @Query(sort: \CommandHistoryItem.timestamp, order: .forward) var commandHistory: [CommandHistoryItem] = []
    @State private var editableInputTextCanvas: String
    @State private var editableInputTextCanvasSelectionLength: Int = 0
    @State private var command = ""
    @StateObject var commandModelStore = CommandModelStore.shared
    @State private var commandInputFocused: Bool
    @FocusState private var canvasFocusState: Bool
    private let onExecute: (String) -> Void
    private let onCancel: () -> Void
//    private var predictedModelString: String {
//        return commandHandler.calculatePromptShortcutModel(for: commandModelStore.command)
//    }
    private var placeholder: String {
        if (!commandInputFocused) {
            return NSLocalizedString("popup.command.placeholder.typeACommand", comment: "Command line placeholder")
        }
        if editableInputTextCanvas.isEmpty {
            return NSLocalizedString("popup.command.placeholder.typeACommandOrEnterQuit", comment: "Command line placeholder")
        } else {
            return NSLocalizedString("popup.command.placeholder.typeACommandOrEnterPaste", comment: "Command line placeholder")
        }
    }
    private var navigationHint: String {
        var elements: [String] = []
        if (!commandInputFocused) {
            elements.append(contentsOf: [NSLocalizedString("popup.navigation.focusCommandline.label", comment: "Navigation hint")])
        } else {
            elements.append(contentsOf: [NSLocalizedString("popup.navigation.focusCanvas.label", comment: "Navigation hint")])
        }
        return elements.joined(separator: " | ")
    }

    private var keyboardHint: String {
        var elements: [String] = []
        if (editableInputTextCanvas != "") {
            elements.append(contentsOf: [NSLocalizedString("popup.shortcut.clearCanvas", comment: "Active shortcuts hint")])
            if (editableInputTextCanvasSelectionLength == 0) {
                if ((systemService.accessGranted && InputsService.lastAppPID != 0) || commandModelStore.command != "") {
                    elements.append(contentsOf: [NSLocalizedString("popup.shortcut.copyCanvas", comment: "Active shortcuts hint")])//same
                } else {
                    if (commandInputFocused) {
                        elements.append(contentsOf: [NSLocalizedString("popup.shortcut.copyCanvasOrEnterCopy", comment: "Active shortcuts hint")])
                    } else {
                        elements.append(contentsOf: [NSLocalizedString("popup.shortcut.copyCanvas", comment: "Active shortcuts hint")])//same
                    }
                }
            }
            if (commandInputFocused && systemService.accessGranted && InputsService.lastAppPID != 0)  {
                elements.append(contentsOf: [NSLocalizedString("popup.shortcut.enterPaste", comment: "Active shortcuts hint") + " " + String(InputsService.lastAppName)])
            }
        } else {
            elements.append(contentsOf: [NSLocalizedString("popup.shortcut.esc", comment: "Active shortcuts hint")])
        }

        return "\(elements.joined(separator: " | "))"
    }

    init(inputText: String, onExecute: @escaping (String) -> Void, onCancel: @escaping () -> Void) {
        self.onExecute = onExecute
        self.onCancel = onCancel
        _editableInputTextCanvas = State(initialValue: inputText)
        self.commandInputFocused = true
    }

    private func onCommandEnter(command: String) {
        if (command == "") {
            onExecute(self.editableInputTextCanvas);
        } else {
            Task {
                do {
                    let historyEntry = CommandHistoryItem(command: command);
                    modelContext.insert(historyEntry)
                    try modelContext.save()
                    let result = try await commandHandler.handleCommand(
                        command: command,
                        editableInputTextCanvas: $editableInputTextCanvas,
                    );
                    editableInputTextCanvas = result;
                    self.commandModelStore.command = "";
                } catch {
                    showErrorAlert(error: error)
                    let errorInfo = error as NSError
                    if let _ = errorInfo.userInfo["openSettings"] as? Bool {
                        openSettings()
                        if let provider = errorInfo.userInfo["apiProvider"] as? String {
                            settingsStore.settingsWindowSelectedTab = .providers
                            settingsStore.settingsWindowProvidersSelectedTab = provider
                        }
                    }
                }
                commandInputFocused = true;
            }
        }
    }

    private func onCopy() {
        NSApp.sendAction(#selector(NSText.copy(_:)), to: nil, from: nil)
        let copiedString = ClipboardService.getString()
        if (copiedString == nil || copiedString == "") {
            ClipboardService.setString(editableInputTextCanvas)
            onExecute("");
        }
    }

    private func clearInputCanvas() {
        editableInputTextCanvas = "";
    }

    private func pasteToInputCanvas() {
        editableInputTextCanvas = ClipboardService.getString() ?? ""
    }

    private func focusCanvas() {
        canvasFocusState = true
    }
    private func focusCommand() {
        commandInputFocused = true
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            UndoableTextEditor(text: $editableInputTextCanvas)
                .font(.system(.body, design: .monospaced))
                .disabled(aiProxyClient.status != .idle)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: UI_INPUT_RADIUS)
                    .fill(UI_INPUT_BACKGROUND_COLOR))
                .overlay(RoundedRectangle(cornerRadius: UI_INPUT_RADIUS)
                    .stroke(UI_INPUT_BORDER_COLOR))
                .focused($canvasFocusState)
                .overlay(
                    RoundedRectangle(cornerRadius: UI_INPUT_RADIUS, style: .continuous)
                        .stroke(canvasFocusState ? UI_INPUT_BORDER_FOCUS_COLOR : UI_INPUT_BORDER_COLOR, lineWidth: 1)
                )
//            Text(predictedModelString)
            CommandTextField(
                text: $commandModelStore.command,
                history: commandHistory.map(\.command),
                hints: promptShortcuts.map(\.command) + StaticCommandsService.getAllCommands(),
                placeholder: NSApp.isActive ? placeholder : "",
                isFieldFocused: $commandInputFocused,
                onSubmit: { command in self.onCommandEnter(command: command) },
            )
                .disabled(aiProxyClient.status != .idle)
                .onReceive(NotificationCenter.default.publisher(
                    for: NSTextView.didChangeSelectionNotification
                )) { notification in
                    if let tv = notification.object as? NSTextView {
                        editableInputTextCanvasSelectionLength = tv.selectedRange.length
                    } else {
                        editableInputTextCanvasSelectionLength = 0
                    }
                }

            HStack(alignment: .center) {
                if aiProxyClient.status == .idle {
                    Image(systemName: "circle")
                } else if aiProxyClient.status == .working {
                    Image(systemName: "circle.fill")
                        .foregroundColor(.accentColor)
                }
                if NSApp.isActive {
                    Text(self.navigationHint)
                        .help(self.navigationHint)
                    Spacer()
                    Text(self.keyboardHint)
                        .help(self.keyboardHint)
                } else {
                    Text(" ")
                }
            }.font(.caption).foregroundColor(Color.gray).lineLimit(1)
        }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.horizontal, 14)
            .padding(.bottom, 14)
            .onAppear {
                commandInputFocused = true
            }
            .onExitCommand(perform: onCancel)
            .overlay(
                Button(action: focusCanvas) { EmptyView() }
                    .keyboardShortcut(.upArrow, modifiers: [.command])
                    .opacity(0)
                    .focusable(false)
                    .frame(width: 0, height: 0)
            )
            .overlay(
                Button(action: focusCommand) { EmptyView() }
                    .keyboardShortcut(.downArrow, modifiers: [.command])
                    .opacity(0)
                    .focusable(false)
                    .frame(width: 0, height: 0)
            )
            .overlay(
                Button(action: onCopy) { EmptyView() }
                    .keyboardShortcut("c", modifiers: [.command])
                    .opacity(0)
                    .focusable(false)
                    .frame(width: 0, height: 0)
            ).overlay(
                Button(action: clearInputCanvas) { EmptyView() }
                    .keyboardShortcut(.delete, modifiers: [.command, .shift])
                    .focusable(false)
                    .opacity(0)
                    .frame(width: 0, height: 0)
            ).overlay(
                Button(action: pasteToInputCanvas) { EmptyView() }
                    .keyboardShortcut("v", modifiers: [.command, .shift])
                    .focusable(false)
                    .opacity(0)
                    .frame(width: 0, height: 0)
            )

    }
}

#Preview {
    CreditsTitleAccessory()
    InlinePopupView(
        inputText: "The quick brown fox jumps over the lazy dog",
        onExecute: { print("Result: \($0)") },
        onCancel: { print("Cancelled") }
    )
}
