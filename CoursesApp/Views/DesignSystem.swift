import SwiftUI

// Modern 2025 Color Scheme
extension Color {
    static let primaryAccent = Color("AccentColor")

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

// Modern Card Style
struct ModernCardStyle: ViewModifier {
    let isPressed: Bool

    func body(content: Content) -> some View {
        content
            .background(Color.cardBackground)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
    }
}

extension View {
    func modernCard() -> some View {
        self.modifier(ModernCardStyle(isPressed: false))
    }
}

// Glassmorphism Effect
struct GlassmorphicBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .cornerRadius(20)
    }
}

extension View {
    func glassmorphic() -> some View {
        self.modifier(GlassmorphicBackground())
    }
}
