import SwiftUI

@MainActor
struct EditableStringListView: View {
    @Binding var items: [String]
    @State private var newItem: String = ""
    
    private func addItem() {
        if !newItem.isEmpty {
            items.append(newItem)
            newItem = ""
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            List {
                ForEach(items.indices, id: \.self) { index in
                    HStack {
                        TextField("Item", text: Binding(
                            get: { items[index] },
                            set: { items[index] = $0 }
                        ))
                        Button {
                            items.remove(at: index)
                        } label: {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
            }
            .cornerRadius(UI_INPUT_RADIUS)
            .overlay(
                RoundedRectangle(cornerRadius: UI_INPUT_RADIUS)
                    .stroke(UI_INPUT_BORDER_COLOR)
            )
            HStack {
                TextField(NSLocalizedString("provider.models.new.placeholder", comment: "Provider config new model input placeholder"), text: $newItem)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit{addItem()}
                Button {
                    addItem()
                } label: { Image(systemName: "plus") }
            }
            .padding(.horizontal, 0)
        }
        .frame(minWidth: 100, minHeight: 100)
    }
}

#Preview {
    SettingsWindow()
        .modelContainer(InlaiderApp.sharedModelContainer)
        .onAppear {
            SettingsStore.shared.settingsWindowSelectedTab = .providers
        }
}
