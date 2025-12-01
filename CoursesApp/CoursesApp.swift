import SwiftUI
import UIKit

// Modern 2025 Color Scheme
extension Color {
    // Adaptive colors for light/dark mode
    static let cardBackground = Color(uiColor: .systemBackground)
    static let secondaryBackground = Color(uiColor: .secondarySystemBackground)
    static let tertiaryBackground = Color(uiColor: .tertiarySystemBackground)

    static let primaryText = Color(uiColor: .label)
    static let secondaryText = Color(uiColor: .secondaryLabel)
    static let tertiaryText = Color(uiColor: .tertiaryLabel)

    // Custom brand colors
    static let success = Color.green
    static let premium = Color.purple
    static let accent = Color.blue
}

// HTML Text View for Rich Content
struct HTMLTextView: View {
    let htmlString: String
    @State private var attributedString: AttributedString?

    var body: some View {
        if let attributedString = attributedString {
            Text(attributedString)
        } else {
            Text(htmlString)
                .onAppear {
                    convertHTMLToAttributedString()
                }
        }
    }

    private func convertHTMLToAttributedString() {
        guard let data = htmlString.data(using: .utf8) else { return }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        if let nsAttributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            attributedString = AttributedString(nsAttributedString)
        }
    }
}

@main
struct CoursesApp: App {
    @StateObject private var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                CoursesListView()
                    .environmentObject(authManager)
            } else {
                LoginView()
                    .environmentObject(authManager)
            }
        }
    }
}
