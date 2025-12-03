import SwiftUI

struct LiveEventsSection: View {
    let events: [LiveEvent]
    let hasSubscription: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "video.fill")
                    .foregroundColor(Color(hex: "FF6B6B"))
                Text("الأحداث المباشرة")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.primaryText)
                Spacer()
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(events.prefix(5)) { event in
                        LiveEventCard(event: event, hasSubscription: hasSubscription)
                    }
                }
            }
        }
    }
}

struct LiveEventCard: View {
    let event: LiveEvent
    let hasSubscription: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Thumbnail
            if let thumbnailUrl = event.thumbnailUrl, let url = URL(string: thumbnailUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.tertiaryBackground
                }
                .frame(height: 120)
                .cornerRadius(12)
                .clipped()
                .overlay(
                    ZStack {
                        Color.black.opacity(0.3)
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    }
                    .cornerRadius(12)
                )
            } else {
                ZStack {
                    Color.tertiaryBackground
                    Image(systemName: "video.fill")
                        .font(.system(size: 32))
                        .foregroundColor(Color(hex: "FF6B6B"))
                }
                .frame(height: 120)
                .cornerRadius(12)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(event.titleAr)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.primaryText)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(event.descriptionAr)
                    .font(.system(size: 13))
                    .foregroundColor(Color.secondaryText)
                    .lineLimit(2)

                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 11))
                    Text(formatEventDate(event.eventDate))
                        .font(.system(size: 12))
                }
                .foregroundColor(Color(hex: "FF6B6B"))
            }

            if hasSubscription {
                if let meetingUrl = event.meetingUrl, let url = URL(string: meetingUrl) {
                    Link(destination: url) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("انضم الآن")
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color(hex: "FF6B6B"))
                        .cornerRadius(8)
                    }
                } else {
                    Text("قريباً")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.secondaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.tertiaryBackground)
                        .cornerRadius(8)
                }
            } else {
                HStack {
                    Image(systemName: "lock.fill")
                    Text("للمشتركين فقط")
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color.premium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.premium.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(12)
        .frame(width: 260)
        .background(Color.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "FF6B6B").opacity(0.2), lineWidth: 1)
        )
    }

    private func formatEventDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ar")
        formatter.dateFormat = "d MMM, h:mm a"
        return formatter.string(from: date)
    }
}
