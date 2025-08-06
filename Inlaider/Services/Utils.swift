import Foundation

func loadLocalizedTextFile(fileName: String, fileExtension: String) -> String? {
    let preferredLanguages = Locale.preferredLanguages
    var languageCandidates: [String] = []
    for lang in preferredLanguages {
        let components = lang.split(separator: "-")
        languageCandidates.append(lang)
        if let short = components.first {
            languageCandidates.append("\(fileName).\(short).\(fileExtension)")
        }
    }
    // fallback language file
    languageCandidates.append("\(fileName).\(fileExtension)")

    for language in languageCandidates {
        let resourcePath = "\(language)"
        if let url = Bundle.main.url(forResource: resourcePath, withExtension: nil) {
            return try? String(contentsOf: url, encoding: .utf8)
        }
    }
    return nil
}


