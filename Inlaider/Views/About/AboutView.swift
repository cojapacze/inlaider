import SwiftUI

struct AboutView: View {
    @State private var showThirdPartyLicenses = false

    private let copyright = Bundle.main.object(forInfoDictionaryKey: "NSHumanReadableCopyright") as? String ?? ""
    private var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "App"
    }

    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
    }

    private var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
    }

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 64, height: 64)
                .cornerRadius(12)
            Text(appName)
                .font(.title)
                .bold()

            Text(String(format: NSLocalizedString("about.version", comment: "About version string"), String("\(version) (\(build))"))
           )
                .font(.subheadline)
                .foregroundColor(.secondary)

            if !copyright.isEmpty {
                Text(copyright)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Divider().padding(.vertical, 4)

            Button(String(format: NSLocalizedString("about.ThirdPartyLicenses", comment: "Third Party Licenses button caption"))) {
                showThirdPartyLicenses = true
            }.sheet(isPresented: $showThirdPartyLicenses) {
                TextModal(
                    title: String(format: NSLocalizedString("about.ThirdPartyLicenses", comment: "Third Party Licenses button caption")),
                    text: loadLocalizedTextFile(fileName: "ThirdPartyLicenses", fileExtension: "md") ?? "N/A"
                )
            }
            Button(
                String(format: NSLocalizedString("about.VisitOnGithub", comment: "Visit on GitHub"))
            ) {
                if let url = URL(string: PROJECT_GITHUB_URL) {
                    NSWorkspace.shared.open(url)
                }
            }

        }
        .padding()
        .frame(width: 420)
    }
}

#Preview {
    AboutView()
}
