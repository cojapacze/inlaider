import SwiftUI
import KeyboardShortcuts
import LaunchAtLogin

struct SettingsGeneralView: View {
    @StateObject private var systemService = SystemService.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 64){
            LabeledContent(
                String(format:
                        NSLocalizedString("settings.inlaiderShortcut.label", comment: "General shortcut settings label"),
                       NSLocalizedString("appName", comment: "App name")
                )
            ) {
                KeyboardShortcuts.Recorder("", name: .showInputAssistant)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .toggleStyle(.checkbox)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .foregroundColor(.accentColor)
            
            LaunchAtLogin.Toggle(NSLocalizedString("settings.LaunchAtLogin.label", comment: "Launch at login checkbox label"))

            Toggle(isOn: Binding(
                get: { systemService.accessGranted },
                set: {
                    _ in AccessibilityPermission.request()
                }
            )) {
                VStack(alignment: .leading, spacing: 4) {
                    Label(NSLocalizedString("settings.accessibility.title", comment: "Accessibility permission settings label"), systemImage: systemService.accessGranted ? "checkmark.circle" : "exclamationmark.circle")
                    Text(NSLocalizedString("settings.accessibility.description", comment: "Accessibility permission settings description"))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

            }
            .disabled(systemService.accessGranted)
            .toggleStyle(.checkbox)

        }.padding(64)
        
    }
}

#Preview {
    SettingsGeneralView()
}
