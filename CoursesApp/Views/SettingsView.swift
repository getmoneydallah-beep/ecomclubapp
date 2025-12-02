import SwiftUI
import Supabase

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    @State private var showDeleteAccountAlert = false
    @State private var showDeleteConfirmation = false
    @State private var isDeleting = false
    @State private var deleteError: String?

    // Get app version
    private var appVersion: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return "\(version) (\(build))"
        }
        return "1.0 (1)"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.primaryBackground
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // User Info Section
                        UserProfileSection(user: authManager.currentUser)

                        // Legal & Compliance Section
                        LegalSection()

                        // Support Section
                        SupportSection()

                        // Account Section
                        AccountSection(
                            onSignOut: {
                                Task {
                                    await authManager.signOut()
                                    dismiss()
                                }
                            },
                            onDeleteAccount: {
                                showDeleteAccountAlert = true
                            }
                        )

                        // App Info
                        AppVersionSection(version: appVersion)
                    }
                    .frame(maxWidth: 600)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("الإعدادات")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primaryText)
                    }
                }
            }
            .environment(\.layoutDirection, .rightToLeft)
            .preferredColorScheme(.dark)
            .alert("حذف الحساب", isPresented: $showDeleteAccountAlert) {
                Button("إلغاء", role: .cancel) { }
                Button("حذف", role: .destructive) {
                    showDeleteConfirmation = true
                }
            } message: {
                Text("هل أنت متأكد من حذف حسابك؟ سيتم حذف جميع بياناتك بشكل نهائي ولا يمكن التراجع عن هذا الإجراء.")
            }
            .alert("تأكيد نهائي", isPresented: $showDeleteConfirmation) {
                Button("إلغاء", role: .cancel) { }
                Button("حذف نهائياً", role: .destructive) {
                    Task {
                        await deleteAccount()
                    }
                }
            } message: {
                Text("هذا الإجراء لا يمكن التراجع عنه. سيتم حذف جميع بياناتك ودوراتك بشكل دائم.")
            }
            .alert("خطأ", isPresented: .constant(deleteError != nil)) {
                Button("حسناً", role: .cancel) {
                    deleteError = nil
                }
            } message: {
                if let error = deleteError {
                    Text(error)
                }
            }
        }
    }

    private func deleteAccount() async {
        isDeleting = true
        deleteError = nil

        do {
            if let userId = authManager.currentUser?.id {
                // Call delete account API (you'll need to implement this in AuthManager)
                try await authManager.deleteAccount(userId: userId)
                dismiss()
            }
        } catch {
            deleteError = "فشل حذف الحساب. يرجى المحاولة مرة أخرى أو التواصل مع الدعم."
        }

        isDeleting = false
    }
}

// Section Header
struct SectionHeader: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.tertiaryText)
                .textCase(.uppercase)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }
}

// Settings Link Row (opens external links)
struct SettingsLinkRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    let iconColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 40, height: 40)

                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(iconColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primaryText)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.secondaryText)
                    }
                }

                Spacer()

                Image(systemName: "arrow.up.left")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.tertiaryText)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.cardBackground)
        }
    }
}

// Settings Action Row (performs action)
struct SettingsActionRow: View {
    let icon: String
    let title: String
    let iconColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 40, height: 40)

                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(iconColor)
                }

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primaryText)

                Spacer()

                Image(systemName: "chevron.left")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.tertiaryText)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.cardBackground)
        }
    }
}

// User Profile Section
struct UserProfileSection: View {
    let user: User?

    var body: some View {
        if let user = user {
            VStack(spacing: 16) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color.accentDim)
                        .frame(width: 80, height: 80)
                        .blur(radius: 20)

                    Circle()
                        .fill(Color.cardBackground)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Circle()
                                .strokeBorder(Color.accent, lineWidth: 2)
                        )

                    Text(String(user.email?.prefix(1) ?? "U").uppercased())
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.accent)
                }

                VStack(spacing: 6) {
                    if let fullName = user.userMetadata["full_name"] as? String {
                        Text(fullName)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primaryText)
                    }

                    if let email = user.email {
                        Text(email)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondaryText)
                    }
                }
            }
            .padding(.vertical, 20)
        }
    }
}

// Legal Section
struct LegalSection: View {
    var body: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "القانونية والخصوصية")

            SettingsLinkRow(
                icon: "shield.checkered",
                title: "سياسة الخصوصية",
                iconColor: .accent
            ) {
                if let url = URL(string: "https://ecomclub.net/privacy-policy") {
                    UIApplication.shared.open(url)
                }
            }

            Divider()
                .background(Color.tertiaryBackground)
                .padding(.horizontal, 20)

            SettingsLinkRow(
                icon: "doc.text",
                title: "شروط الاستخدام",
                iconColor: .accent
            ) {
                if let url = URL(string: "https://ecomclub.net/terms") {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
}

// Support Section
struct SupportSection: View {
    var body: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "الدعم والمساعدة")

            SettingsLinkRow(
                icon: "envelope.fill",
                title: "تواصل معنا",
                subtitle: "support@econabdullah.com",
                iconColor: .premium
            ) {
                if let url = URL(string: "mailto:support@econabdullah.com") {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
}

// Account Section
struct AccountSection: View {
    let onSignOut: () -> Void
    let onDeleteAccount: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "الحساب")

            SettingsActionRow(
                icon: "rectangle.portrait.and.arrow.right",
                title: "تسجيل الخروج",
                iconColor: .secondaryText,
                action: onSignOut
            )

            Divider()
                .background(Color.tertiaryBackground)
                .padding(.horizontal, 20)

            SettingsActionRow(
                icon: "trash.fill",
                title: "حذف الحساب",
                iconColor: .danger,
                action: onDeleteAccount
            )
        }
    }
}

// App Version Section
struct AppVersionSection: View {
    let version: String

    var body: some View {
        VStack(spacing: 12) {
            Text("الإصدار")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.tertiaryText)

            Text(version)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondaryText)
        }
        .padding(.top, 20)
        .padding(.bottom, 40)
    }
}
