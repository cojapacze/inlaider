import SwiftUI
import AppKit

final class FocusAwareTextField: NSTextField {
    var onFocusChange: ((Bool) -> Void)?
    override func becomeFirstResponder() -> Bool {
        let ok = super.becomeFirstResponder()
        if ok { onFocusChange?(true) }
        return ok
    }
}

struct CommandTextFieldRepresentable: NSViewRepresentable {
    @Binding var text: String
    var history: [String]
    var hints: [String]
    var placeholder: String = ""
    @Binding var isFieldFocused: Bool
    var onSubmit: ((String) -> Void)?

    private let fontSize: CGFloat = UI_INPUT_FONT_SIZE

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text,
                           history: history,
                           hints: hints,
                           isFieldFocused: $isFieldFocused,
                           onSubmit: onSubmit)
    }

    func makeNSView(context: Context) -> FocusAwareTextField {
        let field = FocusAwareTextField(string: text)
        field.placeholderString = placeholder
        field.isBordered       = false
        field.isBezeled        = false
        field.drawsBackground  = false
        field.backgroundColor  = .clear
        field.focusRingType    = .none
        field.delegate         = context.coordinator
        field.font             = NSFont.systemFont(ofSize: UI_INPUT_FONT_SIZE)
        field.cell?.usesSingleLineMode = true
        field.onFocusChange = { focused in
            DispatchQueue.main.async { self.isFieldFocused = focused }
        }
        context.coordinator.textField = field
        return field
    }

    func updateNSView(_ nsView: FocusAwareTextField, context: Context) {
        nsView.stringValue = text
        let isFocusedCheck = nsView.window?.firstResponder == nsView.currentEditor()
        if !isFocusedCheck && isFieldFocused {
            nsView.window?.makeFirstResponder(nsView)
        }
        if nsView.font?.pointSize != fontSize {
            nsView.font = NSFont.systemFont(ofSize: fontSize)
        }
        context.coordinator.history = history
        context.coordinator.hints = hints
        context.coordinator.textField?.placeholderString = placeholder
    }

    class Coordinator: NSObject, NSTextFieldDelegate {
        @Binding var text: String
        var history: [String]
        private var historyIndex: Int?
        @Binding var isFieldFocused: Bool
        var hints: [String]
        private var onSubmit: ((String) -> Void)?
        weak var textField: NSTextField?
        private var hintIndex: Int?
        private var hintBasePrefix: String?

        init(text: Binding<String>,
             history: [String],
             hints: [String],
             isFieldFocused: Binding<Bool>,
             onSubmit: ((String) -> Void)?) {
            _text = text
            self.history = history
            _isFieldFocused = isFieldFocused
            self.hints = hints
            self.onSubmit = onSubmit
        }

        func controlTextDidChange(_ obj: Notification) {
            if let field = obj.object as? NSTextField {
                self.text = field.stringValue
                // reset the hint cycle after each user edit
                hintIndex = nil
                hintBasePrefix = nil
                // reset also history cycle index
                historyIndex = nil
            }
        }
        // seems to be redundant to the onFocusChange(true) event
//        func controlTextDidBeginEditing(_ obj: Notification) {
//            isFieldFocused = true
//        }

        func controlTextDidEndEditing(_ obj: Notification) {
            isFieldFocused = false
        }

        private func submit() {
            onSubmit?(text)
            historyIndex = nil
            hintIndex = nil
            hintBasePrefix = nil
        }

        func control(_ control: NSControl, textView: NSTextView, doCommandBy selector: Selector) -> Bool {
            switch selector {
            case #selector(NSResponder.insertNewline(_:)),
                #selector(NSResponder.insertLineBreak(_:)):
                submit();
                return true

            case #selector(NSResponder.insertTab(_:)):
                if let hint = currentHintSuffix {
                    text += hint
                    return true
                }
                return true

            case #selector(NSResponder.moveUp(_:)):
                return handleArrow(direction: "UP")

            case #selector(NSResponder.moveDown(_:)):
                return handleArrow(direction: "DOWN")

            default:
                historyIndex = nil
            }
            return false
        }

        private func handleArrow(direction: String) -> Bool {
            
            let isAllSelected: Bool = {
                guard let tf = textField,
                      let editor = tf.currentEditor() else { return false }
                return editor.selectedRange.length == (tf.stringValue as NSString).length
            }()

            // rotate history
            if text.isEmpty || isAllSelected {
                guard !history.isEmpty else { return true }
                if direction == "UP" {
                    if historyIndex == nil {
                        historyIndex = history.count - 1
                    } else if historyIndex! > 0 {
                        historyIndex! -= 1
                    }
                    text = history[historyIndex!]
                } else if direction == "DOWN" {
                    if let index = historyIndex, index < history.count - 1 {
                        historyIndex = index + 1
                        text = history[historyIndex!]
                    } else {
                        historyIndex = nil
                        text = ""
                    }
                }
                return true
            }

            // rotate hints
            let base: String
            if let existing = hintBasePrefix, text.hasPrefix(existing) {
                base = existing
            } else {
                hintBasePrefix = text
                base = text
                hintIndex = nil
            }

            let matches = hints.filter { $0.hasPrefix(base) && $0 != base }
            guard !matches.isEmpty else { return true }

            if hintIndex == nil {
                // first arrow hit - just show extended current hint
                hintIndex = 0;
            } else {
                if direction == "UP" {
                    hintIndex = (hintIndex! - 1 + matches.count) % matches.count
                } else if direction == "DOWN" {
                    hintIndex = (hintIndex! + 1) % matches.count
                }
            }

            text = matches[hintIndex!]
            historyIndex = nil
            return true
        }

//        func focus() {
//            textField?.window?.makeFirstResponder(textField)
//        }

        private var currentHintSuffix: String? {
            guard !text.isEmpty else { return nil }
            return hints.first(where: { $0.hasPrefix(text) && $0 != text })
                .map { String($0.dropFirst(text.count)) }
        }
    }
}

struct CommandTextField: View {
    @Binding var text: String
    var history: [String]
    var hints: [String]
    var placeholder: String = ""
    @Binding var isFieldFocused: Bool
    var onSubmit: ((String) -> Void)? = nil

    private let fontSize: CGFloat = UI_INPUT_FONT_SIZE
    private let horizontalPadding: CGFloat = 12
    private let verticalPadding: CGFloat = 8
    private let borderRadius: CGFloat = UI_INPUT_RADIUS
    
    private var currentHint: String {
        guard !text.isEmpty else { return "" }
        return hints.first(where: { $0.hasPrefix(text) && $0 != text })
            .map { String($0) } ?? ""
    }

    var body: some View {
        ZStack(alignment: .leading) {
            TextField(currentHint, text: .constant(""))
                .disabled(true)
                .focusable(false)
                .allowsHitTesting(false)
                .textFieldStyle(.plain)
                .background(Color.clear)
                .padding(.vertical, verticalPadding)
                .padding(.horizontal, horizontalPadding)
                .font(.system(size: fontSize))
            CommandTextFieldRepresentable(
                text: $text,
                history: history,
                hints: hints,
                placeholder: placeholder,
                isFieldFocused: $isFieldFocused,
                onSubmit: onSubmit
            )
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
        }
        .background(
            RoundedRectangle(cornerRadius: borderRadius, style: .continuous)
                .fill(UI_INPUT_BACKGROUND_COLOR)
        )
        .overlay(
            RoundedRectangle(cornerRadius: borderRadius, style: .continuous)
                .stroke(isFieldFocused ? UI_INPUT_BORDER_FOCUS_COLOR : UI_INPUT_BORDER_COLOR, lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.03), value: isFieldFocused)
    }
}

#Preview {
    InlinePopupView(
        inputText: "The quick brown fox jumps over the lazy dog",
        onExecute: { print("Result: \($0)") },
        onCancel: { print("Cancelled") }
    )
}
