import SwiftUI

struct SplashView: View {
    @State private var opacity: Double = 0
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
        ZStack {
            Color.clear // keep window transparent
            VStack(spacing: 16) {
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
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
            .shadow(radius: 12)
            .opacity(opacity)
            .onAppear { withAnimation(.easeInOut(duration: 0.35)) { opacity = 1 } }
        }
        .frame(width: 420, height: 300)
    }
}

#Preview {
    SplashView()
}
