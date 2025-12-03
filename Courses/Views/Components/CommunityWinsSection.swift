import SwiftUI

struct CommunityWinsSection: View {
    let wins: [CommunityWin]
    let hasSubscription: Bool
    let onCreateWin: () -> Void
    let onRefresh: () async -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundColor(Color.premium)
                Text("إنجازات المجتمع")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.primaryText)
                Spacer()

                if hasSubscription {
                    Button(action: onCreateWin) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color.accent)
                    }
                }
            }

            if wins.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "trophy")
                        .font(.system(size: 40))
                        .foregroundColor(Color.secondaryText)
                    Text("لا توجد إنجازات حالياً")
                        .font(.system(size: 14))
                        .foregroundColor(Color.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(Color.cardBackground)
                .cornerRadius(12)
            } else {
                VStack(spacing: 12) {
                    ForEach(wins.prefix(5)) { win in
                        CommunityWinCard(win: win)
                    }
                }
            }
        }
    }
}

struct CommunityWinCard: View {
    let win: CommunityWin

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // User info
            HStack(spacing: 10) {
                if let avatarUrl = win.profiles?.avatarUrl, let url = URL(string: avatarUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .foregroundColor(Color.secondaryText)
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .foregroundColor(Color.secondaryText)
                        .frame(width: 40, height: 40)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(win.profiles?.fullName ?? "مستخدم")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.primaryText)

                    Text(formatDate(win.createdAt))
                        .font(.system(size: 12))
                        .foregroundColor(Color.secondaryText)
                }

                Spacer()

                // Win type badge
                Text(win.winType.displayName)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color.premium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.premium.opacity(0.1))
                    .cornerRadius(6)
            }

            // Title and description
            VStack(alignment: .leading, spacing: 6) {
                Text(win.titleAr)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.primaryText)

                if let description = win.descriptionAr {
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(Color.secondaryText)
                        .lineLimit(3)
                }
            }

            // Reactions and comments
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "hand.thumbsup.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color.accent)
                    Text("\(win.reactionsCount ?? 0)")
                        .font(.system(size: 13))
                        .foregroundColor(Color.secondaryText)
                }

                HStack(spacing: 4) {
                    Image(systemName: "bubble.left.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color.secondaryText)
                    Text("\(win.commentsCount ?? 0)")
                        .font(.system(size: 13))
                        .foregroundColor(Color.secondaryText)
                }

                Spacer()
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.premium.opacity(0.2), lineWidth: 1)
        )
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ar")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
