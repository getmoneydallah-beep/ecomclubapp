import SwiftUI

struct AnnouncementsBanner: View {
    let announcements: [Announcement]
    @State private var currentIndex = 0

    var body: some View {
        VStack(spacing: 0) {
            if !announcements.isEmpty {
                let announcement = announcements[currentIndex]

                HStack(spacing: 12) {
                    // Icon based on type
                    Image(systemName: iconForType(announcement.type))
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(colorForType(announcement.type))
                        .frame(width: 36, height: 36)
                        .background(colorForType(announcement.type).opacity(0.15))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text(announcement.titleAr)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.primaryText)
                            .lineLimit(1)

                        Text(announcement.contentAr)
                            .font(.system(size: 12))
                            .foregroundColor(Color.secondaryText)
                            .lineLimit(2)
                    }

                    Spacer()

                    if let linkUrl = announcement.linkUrl, let linkText = announcement.linkTextAr {
                        Button(action: {
                            // Navigate to link
                        }) {
                            Text(linkText)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color.accent)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.accent.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(colorForType(announcement.type).opacity(0.3), lineWidth: 1)
                )

                // Pagination dots
                if announcements.count > 1 {
                    HStack(spacing: 6) {
                        ForEach(0..<announcements.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentIndex ? Color.accent : Color.tertiaryText)
                                .frame(width: 6, height: 6)
                        }
                    }
                    .padding(.top, 8)
                }
            }
        }
        .onAppear {
            startAutoRotation()
        }
    }

    private func iconForType(_ type: AnnouncementType) -> String {
        switch type {
        case .general: return "megaphone.fill"
        case .newCourse: return "book.fill"
        case .challenge: return "flag.fill"
        case .liveEvent: return "video.fill"
        }
    }

    private func colorForType(_ type: AnnouncementType) -> Color {
        switch type {
        case .general: return Color.accent
        case .newCourse: return Color.premium
        case .challenge: return Color.success
        case .liveEvent: return Color(hex: "FF6B6B")
        }
    }

    private func startAutoRotation() {
        guard announcements.count > 1 else { return }

        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            withAnimation {
                currentIndex = (currentIndex + 1) % announcements.count
            }
        }
    }
}
