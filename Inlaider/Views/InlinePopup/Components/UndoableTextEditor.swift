import SwiftUI
import AppKit

struct UndoableTextEditor: NSViewRepresentable {
    @Binding var text: String
    @Environment(\.isEnabled) private var isEnabled

    var onDisappear: (() -> Void)? = nil

    func makeCoordinator() -> Coordinator {
        Coordinator(self, onDisappear: onDisappear)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scroll = NSScrollView()
        scroll.hasVerticalScroller = true
        scroll.autohidesScrollers = true
        scroll.drawsBackground = false

        let tv = NSTextView()
        tv.isRichText = false
        tv.isEditable = isEnabled
        tv.isSelectable = true
        tv.allowsUndo = true
        tv.delegate = context.coordinator
        tv.string = text
        tv.font = .systemFont(ofSize: UI_INPUT_FONT_SIZE)
        tv.isVerticallyResizable = true
        tv.isHorizontallyResizable = false
        tv.autoresizingMask = [.width]
        tv.textContainer?.widthTracksTextView = true
        tv.textContainer?.containerSize = NSSize(
            width: scroll.contentSize.width,
            height: .greatestFiniteMagnitude,
        )
        tv.undoManager?.removeAllActions()
        scroll.documentView = tv
        scrollToBottom(tv);
        return scroll
    }

    private func scrollToBottom(_ tv: NSTextView) {
//        print("IS ENABLED: \(isEnabled)")
        if (isEnabled) {
            tv.textColor = NSColor.textColor
        } else {
            tv.textColor = NSColor.disabledControlTextColor
            let bottom = NSRange(location: tv.string.count, length: 0)
            tv.scrollRangeToVisible(bottom)
        }
    }

    func updateNSView(_ scroll: NSScrollView, context: Context) {
        guard let tv = scroll.documentView as? NSTextView else { return }
        if (tv.string != text) {
            context.coordinator.apply(text: text, to: tv)
        }
        scrollToBottom(tv);
    }

    class Coordinator: NSObject, NSTextFieldDelegate, NSTextViewDelegate {
        private let parent: UndoableTextEditor
        private var isInternalEdit = false
        private let onDisappear: (() -> Void)?
        func control(_ control: NSControl, textView: NSTextView, doCommandBy selector: Selector) -> Bool {
            print("control")
            return true;
        }

        init(_ parent: UndoableTextEditor, onDisappear: (() -> Void)?) {
            self.parent = parent
            self.onDisappear = onDisappear
        }

        deinit {
            onDisappear?()
        }

        func apply(text newText: String, to textView: NSTextView) {
            let oldText = textView.string
            if let undo = textView.undoManager {
                undo.registerUndo(withTarget: self) { coord in
                    coord.apply(text: oldText, to: textView)
                }
                undo.setActionName("Replace Text")
            }
            isInternalEdit = true
            textView.string = newText
            isInternalEdit = false
            parent.text = newText
        }

        func textDidChange(_ note: Notification) {
            guard !isInternalEdit,
                  let tv = note.object as? NSTextView else { return }
            parent.text = tv.string
        }
    }
}

#Preview {
    InlinePopupView(
        inputText: "The quick brown fox jumps over the lazy dog",
        onExecute: { print("Result: \($0)") },
        onCancel: { print("Cancelled") }
    )
}
