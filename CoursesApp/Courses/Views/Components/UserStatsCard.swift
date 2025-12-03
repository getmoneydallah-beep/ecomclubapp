import SwiftUI

struct UserStatsCard: View {
    let stats: UserStats

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("إحصائياتك")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color.primaryText)

                Spacer()

                Image(systemName: "chart.bar.fill")
                    .foregroundColor(Color.accent)
            }

            HStack(spacing: 12) {
                StatItem(
                    icon: "checkmark.circle.fill",
                    value: "\(stats.completedCourses)",
                    label: "دورة مكتملة",
                    color: Color.success
                )

                StatItem(
                    icon: "flag.fill",
                    value: "\(stats.activeChallenges)",
                    label: "تحدي نشط",
                    color: Color.accent
                )

                StatItem(
                    icon: "trophy.fill",
                    value: "\(stats.communityWins)",
                    label: "إنجاز",
                    color: Color.premium
                )

                StatItem(
                    icon: "flame.fill",
                    value: "\(stats.daysStreak)",
                    label: "يوم متتالي",
                    color: Color(hex: "FF6B6B")
                )
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.cardBackground,
                    Color.cardBackground.opacity(0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.accent.opacity(0.3),
                            Color.premium.opacity(0.3)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.15))
                .clipShape(Circle())

            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color.primaryText)

            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Color.secondaryText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
    }
}
