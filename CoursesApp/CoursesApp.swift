import SwiftUI
import UIKit

// Premium Fintech Dark Theme 2025
extension Color {
    // Dark backgrounds - deep blacks and charcoals
    static let primaryBackground = Color(hex: "000000")      // Pure black
    static let secondaryBackground = Color(hex: "0A0A0A")    // Deep charcoal
    static let tertiaryBackground = Color(hex: "111111")     // Dark charcoal
    static let cardBackground = Color(hex: "0F0F0F")         // Card background
    static let inputBackground = Color(hex: "1A1A1A")        // Input fields

    // Text colors - high contrast
    static let primaryText = Color(hex: "FFFFFF")            // Pure white
    static let secondaryText = Color(hex: "A0A0A0")          // Light gray
    static let tertiaryText = Color(hex: "666666")           // Medium gray

    // Premium accent - electric cyan/teal
    static let accent = Color(hex: "00FFF0")                 // Electric cyan
    static let accentGlow = Color(hex: "00FFF0").opacity(0.3)
    static let accentDim = Color(hex: "00FFF0").opacity(0.1)

    // Status colors
    static let success = Color(hex: "00FF88")                // Neon green
    static let premium = Color(hex: "FFD700")                // Gold
    static let danger = Color(hex: "FF3B30")                 // Red

    // Hex color initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
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
                .foregroundColor(.primaryText)
                .onAppear {
                    convertHTMLToAttributedString()
                }
        }
    }

    private func convertHTMLToAttributedString() {
        guard htmlString.data(using: .utf8) != nil else { return }

        // Add CSS styling to force white text color
        let styledHTML = """
        <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', sans-serif;
            font-size: 15px;
            line-height: 1.6;
            color: #FFFFFF !important;
        }
        p, div, span, li, ul, ol {
            color: #FFFFFF !important;
        }
        strong, b {
            color: #FFFFFF !important;
            font-weight: 600;
        }
        a {
            color: #00FFF0 !important;
            text-decoration: underline;
        }
        ul, ol {
            padding-left: 20px;
            margin: 8px 0;
        }
        li {
            margin: 4px 0;
        }
        </style>
        \(htmlString)
        """

        guard let styledData = styledHTML.data(using: .utf8) else { return }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        if let nsAttributedString = try? NSAttributedString(data: styledData, options: options, documentAttributes: nil) {
            var attrString = AttributedString(nsAttributedString)

            // Ensure white text color for all text
            attrString.foregroundColor = .primaryText

            attributedString = attrString
        }
    }
}

@main
struct CoursesApp: App {
    @StateObject private var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                MainTabView()
                    .environmentObject(authManager)
            } else {
                LoginView()
                    .environmentObject(authManager)
            }
        }
    }
}

// Main Tab View with Bottom Navigation
struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeView()
                .tabItem {
                    Label("الرئيسية", systemImage: "house.fill")
                }
                .tag(0)

            // Resources Tab
            ResourcesView()
                .tabItem {
                    Label("المصادر", systemImage: "folder.fill")
                }
                .tag(1)

            // Business Card Tab
            BusinessCardView()
                .tabItem {
                    Label("بطاقة العضوية", systemImage: "person.text.rectangle.fill")
                }
                .tag(2)
        }
        .accentColor(Color.accent)
        .onAppear {
            // Customize tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color.cardBackground)

            // Normal state
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.secondaryText)
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor(Color.secondaryText)
            ]

            // Selected state
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.accent)
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor(Color.accent)
            ]

            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}
