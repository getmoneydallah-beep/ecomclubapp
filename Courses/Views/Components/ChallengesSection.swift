import SwiftUI

struct ChallengesSection: View {
    let challenges: [Challenge]
    let userChallenges: [UserChallenge]
    let onStartChallenge: (Challenge) async -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "flag.fill")
                    .foregroundColor(Color.accent)
                Text("التحديات")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.primaryText)
                Spacer()
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(challenges.prefix(5)) { challenge in
                        ChallengeCard(
                            challenge: challenge,
                            isActive: isUserChallengeActive(challenge.id),
                            onStart: {
                                Task {
                                    await onStartChallenge(challenge)
                                }
                            }
                        )
                    }
                }
            }
        }
    }

    private func isUserChallengeActive(_ challengeId: UUID) -> Bool {
        userChallenges.contains { $0.challengeId == challengeId && $0.completedAt == nil }
    }
}

struct ChallengeCard: View {
    let challenge: Challenge
    let isActive: Bool
    let onStart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Thumbnail or placeholder
            if let thumbnailUrl = challenge.thumbnailUrl, let url = URL(string: thumbnailUrl) {
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
            } else {
                ZStack {
                    Color.tertiaryBackground
                    Image(systemName: "flag.fill")
                        .font(.system(size: 32))
                        .foregroundColor(Color.accent)
                }
                .frame(height: 120)
                .cornerRadius(12)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(challenge.titleAr)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.primaryText)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(challenge.descriptionAr)
                    .font(.system(size: 13))
                    .foregroundColor(Color.secondaryText)
                    .lineLimit(2)

                HStack {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 11))
                    Text("\(challenge.durationDays) أيام")
                        .font(.system(size: 12))
                }
                .foregroundColor(Color.accent)
            }

            if isActive {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.success)
                    Text("جاري التنفيذ")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.success)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.success.opacity(0.1))
                .cornerRadius(8)
            } else {
                Button(action: onStart) {
                    Text("ابدأ التحدي")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color.primaryBackground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.accent)
                        .cornerRadius(8)
                }
            }
        }
        .padding(12)
        .frame(width: 240)
        .background(Color.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.accent.opacity(0.2), lineWidth: 1)
        )
    }
}
