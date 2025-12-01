import SwiftUI

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
