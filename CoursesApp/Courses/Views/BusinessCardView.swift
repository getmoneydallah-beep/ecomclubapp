import SwiftUI
import UIKit

struct BusinessCardView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var affiliate: Affiliate?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showingShareSheet = false
    @State private var showingExportOptions = false
    @State private var cardImage: UIImage?
    @State private var showCopiedAlert = false

    private let affiliatesService = AffiliatesService()

    var body: some View {
        NavigationStack {
            ZStack {
                // Premium gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.primaryBackground,
                        Color.secondaryBackground,
                        Color.tertiaryBackground
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                if isLoading {
                    ProgressView()
                        .tint(Color.accent)
                } else if let error = errorMessage {
                    PremiumErrorView(message: error) {
                        Task { await loadAffiliate() }
                    }
                } else if let affiliate = affiliate {
                    ScrollView {
                        VStack(spacing: 30) {
                            // Card Preview
                            BusinessCardPreview(
                                fullName: authManager.currentUser?.userMetadata?["full_name"] as? String ?? "عضو",
                                referralCode: affiliate.referralCode
                            )
                            .padding(.top, 20)

                            // Stats Cards
                            HStack(spacing: 12) {
                                AffiliateStatCard(
                                    icon: "person.2.fill",
                                    value: "\(affiliate.totalReferrals ?? 0)",
                                    label: "إحالة",
                                    color: Color.accent
                                )

                                AffiliateStatCard(
                                    icon: "dollarsign.circle.fill",
                                    value: String(format: "%.0f", affiliate.totalEarnings ?? 0),
                                    label: "ريال",
                                    color: Color.premium
                                )
                            }

                            // Action Buttons
                            VStack(spacing: 12) {
                                // Copy Referral Code Button
                                Button(action: copyReferralCode) {
                                    HStack {
                                        Image(systemName: "doc.on.doc.fill")
                                        Text("نسخ رمز الإحالة")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                    .foregroundColor(Color.primaryBackground)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.accent, Color.accent.opacity(0.8)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(12)
                                }

                                // Export Card Button
                                Button(action: {
                                    showingExportOptions = true
                                }) {
                                    HStack {
                                        Image(systemName: "square.and.arrow.up.fill")
                                        Text("تصدير البطاقة")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                    .foregroundColor(Color.primaryText)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.cardBackground)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [Color.accent, Color.premium]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                                }

                                // Share Link Button
                                Button(action: shareReferralLink) {
                                    HStack {
                                        Image(systemName: "link.circle.fill")
                                        Text("مشاركة الرابط")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                    .foregroundColor(Color.primaryText)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.cardBackground)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.premium.opacity(0.3), lineWidth: 1)
                                    )
                                }
                            }

                            // Info Section
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(Color.accent)
                                    Text("كيف تستخدم بطاقتك؟")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Color.primaryText)
                                }

                                VStack(alignment: .leading, spacing: 8) {
                                    InfoBullet(text: "شارك رمز الإحالة مع الأصدقاء")
                                    InfoBullet(text: "احصل على عمولة عن كل اشتراك")
                                    InfoBullet(text: "صدّر البطاقة وشاركها على وسائل التواصل")
                                }
                            }
                            .padding()
                            .background(Color.cardBackground)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.accent.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("بطاقة العضوية")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await loadAffiliate()
            }
            .sheet(isPresented: $showingShareSheet) {
                if let image = cardImage {
                    ShareSheet(items: [image])
                }
            }
            .confirmationDialog("تصدير البطاقة", isPresented: $showingExportOptions) {
                Button("حفظ كصورة PNG") {
                    exportCardAsImage()
                }
                Button("مشاركة الصورة") {
                    exportAndShare()
                }
                Button("إلغاء", role: .cancel) {}
            }
            .alert("تم النسخ!", isPresented: $showCopiedAlert) {
                Button("حسناً", role: .cancel) {}
            } message: {
                Text("تم نسخ رمز الإحالة إلى الحافظة")
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }

    private func loadAffiliate() async {
        isLoading = true
        errorMessage = nil

        guard let userId = authManager.currentUser?.id else {
            errorMessage = "لم يتم العثور على معلومات المستخدم"
            isLoading = false
            return
        }

        do {
            affiliate = try await affiliatesService.fetchUserAffiliate(userId: userId)
            isLoading = false
        } catch {
            errorMessage = "فشل في تحميل بيانات الإحالة: \(error.localizedDescription)"
            isLoading = false
        }
    }

    private func copyReferralCode() {
        guard let code = affiliate?.referralCode else { return }
        UIPasteboard.general.string = code
        showCopiedAlert = true
    }

    private func shareReferralLink() {
        guard let code = affiliate?.referralCode else { return }
        let link = "https://ecomclub.app?ref=\(code)"
        let activityVC = UIActivityViewController(
            activityItems: [link],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }

    private func exportCardAsImage() {
        guard let affiliate = affiliate else { return }
        let fullName = authManager.currentUser?.userMetadata?["full_name"] as? String ?? "عضو"

        let renderer = ImageRenderer(content:
            BusinessCardPreview(fullName: fullName, referralCode: affiliate.referralCode)
                .frame(width: 400, height: 240)
        )

        if let image = renderer.uiImage {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }

    private func exportAndShare() {
        guard let affiliate = affiliate else { return }
        let fullName = authManager.currentUser?.userMetadata?["full_name"] as? String ?? "عضو"

        let renderer = ImageRenderer(content:
            BusinessCardPreview(fullName: fullName, referralCode: affiliate.referralCode)
                .frame(width: 400, height: 240)
        )

        if let image = renderer.uiImage {
            cardImage = image
            showingShareSheet = true
        }
    }
}

struct BusinessCardPreview: View {
    let fullName: String
    let referralCode: String

    var body: some View {
        ZStack {
            // Background with premium gradient
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.primaryBackground,
                            Color.secondaryBackground
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Gold border gradient
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.premium,
                            Color.accent,
                            Color.premium
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )

            VStack(spacing: 20) {
                // Logo/Icon
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.premium, Color.accent]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // User Info
                VStack(spacing: 8) {
                    Text(fullName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.primaryText)

                    Text("عضو نادي التجارة الإلكترونية")
                        .font(.system(size: 14))
                        .foregroundColor(Color.secondaryText)
                }

                // Referral Code
                VStack(spacing: 8) {
                    Text("رمز الإحالة")
                        .font(.system(size: 12))
                        .foregroundColor(Color.secondaryText)

                    Text(referralCode)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.accent, Color.premium]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.premium.opacity(0.1))
                        .cornerRadius(10)
                }
            }
            .padding(30)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(16/9, contentMode: .fit)
    }
}

struct AffiliateStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color.primaryText)

            Text(label)
                .font(.system(size: 14))
                .foregroundColor(Color.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct InfoBullet: View {
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(Color.accent)
                .frame(width: 6, height: 6)

            Text(text)
                .font(.system(size: 14))
                .foregroundColor(Color.secondaryText)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
