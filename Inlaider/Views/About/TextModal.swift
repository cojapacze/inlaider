import SwiftUI

struct TextModal: View {
    @Environment(\.dismiss) var dismiss
    let title: String
    let text: String

    init(title: String, text: String) {
        self.title = title
        self.text = text
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)

            ScrollView {
                TextEditor(text: .constant(text))
                    .font(.body)
                    .frame(minHeight: 400)
                    .padding()
                    .disabled(true)
            }

            HStack {
                Spacer()
                Button(NSLocalizedString("close", comment: "Popup close button caption")) {
                    dismiss()
                }
            }
        }
        .padding()
        .frame(minWidth: 500, minHeight: 500)
    }
}
