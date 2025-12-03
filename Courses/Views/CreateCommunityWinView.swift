import SwiftUI

struct CreateCommunityWinView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var titleAr = ""
    @State private var descriptionAr = ""
    @State private var selectedWinType: WinType = .firstSale
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var showSuccess = false

    let onSuccess: (Bool) -> Void

    private let communityService = CommunityService()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.primaryBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "trophy.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(Color.premium)

                            Text("شارك إنجازك")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color.primaryText)

                            Text("أخبرنا عن نجاحك وألهم الآخرين")
                                .font(.system(size: 14))
                                .foregroundColor(Color.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)

                        // Form
                        VStack(spacing: 20) {
                            // Win Type Picker
                            VStack(alignment: .leading, spacing: 8) {
                                Text("نوع الإنجاز")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color.primaryText)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(WinType.allCases, id: \.self) { type in
                                            WinTypeButton(
                                                type: type,
                                                isSelected: selectedWinType == type,
                                                action: { selectedWinType = type }
                                            )
                                        }
                                    }
                                }
                            }

                            // Title Input
                            VStack(alignment: .leading, spacing: 8) {
                                Text("العنوان")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color.primaryText)

                                TextField("مثال: حققت أول عملية بيع!", text: $titleAr)
                                    .font(.system(size: 15))
                                    .foregroundColor(Color.primaryText)
                                    .padding()
                                    .background(Color.inputBackground)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.accent.opacity(0.3), lineWidth: 1)
                                    )
                            }

                            // Description Input
                            VStack(alignment: .leading, spacing: 8) {
                                Text("التفاصيل (اختياري)")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color.primaryText)

                                TextEditor(text: $descriptionAr)
                                    .font(.system(size: 15))
                                    .foregroundColor(Color.primaryText)
                                    .frame(height: 120)
                                    .padding(8)
                                    .background(Color.inputBackground)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.accent.opacity(0.3), lineWidth: 1)
                                    )

                                if descriptionAr.isEmpty {
                                    Text("أخبرنا المزيد عن إنجازك...")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.tertiaryText)
                                        .padding(.horizontal, 12)
                                        .padding(.top, -112)
                                        .allowsHitTesting(false)
                                }
                            }

                            // Info Note
                            HStack(spacing: 10) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(Color.accent)
                                Text("سيتم مراجعة إنجازك قبل نشره للمجتمع")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.secondaryText)
                            }
                            .padding()
                            .background(Color.accent.opacity(0.1))
                            .cornerRadius(10)

                            // Error Message
                            if let error = errorMessage {
                                Text(error)
                                    .font(.system(size: 13))
                                    .foregroundColor(Color.danger)
                                    .padding()
                                    .background(Color.danger.opacity(0.1))
                                    .cornerRadius(10)
                            }

                            // Submit Button
                            Button(action: submitWin) {
                                HStack {
                                    if isSubmitting {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Text("نشر الإنجاز")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                }
                                .foregroundColor(.white)
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
                            .disabled(titleAr.isEmpty || isSubmitting)
                            .opacity(titleAr.isEmpty ? 0.5 : 1.0)
                        }
                        .padding()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("إلغاء") {
                        dismiss()
                    }
                    .foregroundColor(Color.secondaryText)
                }
            }
            .alert("تم النشر!", isPresented: $showSuccess) {
                Button("حسناً") {
                    onSuccess(true)
                    dismiss()
                }
            } message: {
                Text("تم إرسال إنجازك للمراجعة. سيظهر في المجتمع بعد الموافقة عليه.")
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }

    private func submitWin() {
        guard let userId = authManager.currentUser?.id else {
            errorMessage = "لم يتم العثور على معلومات المستخدم"
            return
        }

        guard !titleAr.isEmpty else {
            errorMessage = "يرجى إدخال عنوان الإنجاز"
            return
        }

        isSubmitting = true
        errorMessage = nil

        Task {
            do {
                let description = descriptionAr.isEmpty ? nil : descriptionAr
                try await communityService.createWin(
                    userId: userId,
                    titleAr: titleAr,
                    descriptionAr: description,
                    winType: selectedWinType
                )
                isSubmitting = false
                showSuccess = true
            } catch {
                isSubmitting = false
                errorMessage = "فشل في نشر الإنجاز: \(error.localizedDescription)"
            }
        }
    }
}

struct WinTypeButton: View {
    let type: WinType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(type.displayName)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isSelected ? Color.primaryBackground : Color.primaryText)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? Color.premium : Color.cardBackground)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? Color.clear : Color.premium.opacity(0.3), lineWidth: 1)
                )
        }
    }
}
