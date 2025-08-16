import SwiftUI
import AppKit
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let showInputAssistant = Self("showInputAssistant", default: .init(.slash, modifiers: [.option]))
}

let FALLBACK_PROMPT_SHORTCUT = PromptShortcutItem(
    command: "",
    model: DEFAULT_PROVIDER_MODEL_NAME,
    prompt: ""
);
let PROJECT_GITHUB_URL = "https://github.com/cojapacze/inlaider"
let REGION = Locale.current.region?.identifier ?? "unknown region";
let CHINA_BLOCK_ID = "CN";
let UI_INPUT_RADIUS: CGFloat = 12;
let UI_INPUT_FONT_SIZE: CGFloat = 13;
let UI_INPUT_BACKGROUND_COLOR = Color(nsColor: NSColor.textBackgroundColor);
let UI_INPUT_BORDER_COLOR = Color.gray.opacity(0.5)
let UI_INPUT_BORDER_FOCUS_COLOR = Color.accentColor

let INLAIDER_DOMAIN = Bundle.main.bundleIdentifier ?? "unknown";

let AI_QUERY_SECONDS_TO_WAIT: UInt = 60;

let DEFAULT_GENERAL_PROMPT = "Use - instead of —\nDo not add extra comments in your response"
let DEFAULT_PROMPT_COMMAND_KEY = "default"
let DEFAULT_PROVIDER_MODEL_NAME = "OpenAI/gpt-5-nano"
let DEFAULT_PROMPTS = [
    PromptShortcutItem(
        isEditable: false,
        command: DEFAULT_PROMPT_COMMAND_KEY,
        model: DEFAULT_PROVIDER_MODEL_NAME,
        prompt: ""
    ),
    
    // translations
    PromptShortcutItem(isEditable: true, command: "/en",        prompt: "Translate to English"),
    PromptShortcutItem(isEditable: true, command: "/pl",        prompt: "Translate to Polish"),
    PromptShortcutItem(isEditable: true, command: "/de",        prompt: "Translate to German"),
    PromptShortcutItem(isEditable: true, command: "/fr",        prompt: "Translate to French"),
    PromptShortcutItem(isEditable: true, command: "/es",        prompt: "Translate to Spanish"),
    
    // writing tools
    PromptShortcutItem(isEditable: true, command: "/fix",       prompt: "Correct grammar and spelling"),
    PromptShortcutItem(isEditable: true, command: "/shorten",   prompt: "Shorten the text"),
    PromptShortcutItem(isEditable: true, command: "/expand",    prompt: "Expand the text with more detail and examples"),
    PromptShortcutItem(isEditable: true, command: "/formal",    prompt: "Rewrite in a formal tone"),
    PromptShortcutItem(isEditable: true, command: "/casual",    prompt: "Rewrite in a casual tone"),
    
    // shorten
    PromptShortcutItem(isEditable: true, command: "/sumarize",  prompt: "Summarize the text"),
    PromptShortcutItem(isEditable: true, command: "/tldr",      prompt: "Summarize in 3 concise sentences"),
    PromptShortcutItem(isEditable: true, command: "/ELI5",      prompt: "Explain Like I'm 5."),
    
    
    // format
    PromptShortcutItem(isEditable: true, command: "/bullet",    prompt: "Convert to a bulleted list"),
    PromptShortcutItem(isEditable: true, command: "/markdown",  prompt: "Format as Markdown"),
    
    // special
    PromptShortcutItem(isEditable: true, command: "/emoji",     prompt: "Return emoji representation"),
    PromptShortcutItem(isEditable: true, command: "/utf8_icon", prompt: "Return standard UTF-8 icon representation"),
    PromptShortcutItem(isEditable: true, command: "/title",     prompt: "Propose a catchy title or headline"),
    PromptShortcutItem(isEditable: true, command: "/seo",       prompt: "Rewrite the text optimized for SEO (English)"),
    PromptShortcutItem(isEditable: true, command: "/regex",     prompt: "Generate a regex that matches the described pattern"),
    PromptShortcutItem(isEditable: true, command: "/json",      prompt: "Convert the text into valid JSON"),
    PromptShortcutItem(isEditable: true, command: "/csv",       prompt: "Convert the text into CSV format"),
    PromptShortcutItem(isEditable: true, command: "/explain",   prompt: "Explain the code step by step"),
    PromptShortcutItem(isEditable: true, command: "/terminal",  prompt: "You are a terminal assistant on macOS 15 or above. Type valid terminal commands that complete the user request. Try to use built-in commands first."),
    PromptShortcutItem(isEditable: true, command: "/commit",    prompt: "Create clean commit message from description"),
]

