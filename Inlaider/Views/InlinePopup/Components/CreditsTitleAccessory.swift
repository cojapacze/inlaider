import SwiftUI
import SwiftData

class CommandModelStore: ObservableObject {
    static let shared = CommandModelStore();
    @Published var command = ""
}

struct CreditsTitleAccessory: View {
    @Environment(\.openSettings) private var openSettings
    private let aiProxyClient: AIProxyClient = .shared
    @ObservedObject private var settingsStore: SettingsStore = SettingsStore.shared
    private let commandHandler: CommandHandler = .shared
    @StateObject var commandModelStore = CommandModelStore.shared
    private var predictedModel: PromptShortcutItem {
        return commandHandler.calculatePromptShortcutModel(for: commandModelStore.command)
    }
    private var predictedPompt: PromptShortcutItem {
        return commandHandler.calculatePromptShortcutModel(for: commandModelStore.command)
    }

    var body: some View {

        HStack {
            Spacer()
            HStack(spacing: 0) {
                if (predictedModel.providerName == "static") {
                    Text(" ")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .opacity(0.5)
                } else {
                    if (!predictedModel.prompt.isEmpty) {
                        Text("\(predictedModel.prompt)")
                            .help(predictedModel.prompt)
                    } else {
                        Text("\(predictedModel.providerName)/\(predictedModel.modelName)").font(.system(size: 12))
                    }
                }
             }
            .opacity(0.9)
            .onTapGesture {pGesture in
                if (predictedModel.providerName == "static") {
                    print("static");
                } else {
                    openSettings()
                    settingsStore.settingsWindowSelectedTab = .providers
                    settingsStore.settingsWindowProvidersSelectedTab = predictedModel.providerName
                
                }
            }
        }.padding(.horizontal, 8)
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
