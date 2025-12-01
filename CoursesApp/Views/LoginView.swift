import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var fullName = ""
    @State private var isLoading = false

    var body: some View {
        ZStack {
            // Modern gradient background
            LinearGradient(
                colors: [Color.accent.opacity(0.1), Color.premium.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    // App Icon/Logo Area
                    VStack(spacing: 12) {
                        Image(systemName: "graduationcap.circle.fill")
                            .font(.system(size: 70))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.accent, .premium],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        Text(isSignUp ? "إنشاء حساب جديد" : "مرحباً بك")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.primaryText)

                        Text(isSignUp ? "انضم إلى منصة الدورات" : "سجل الدخول للمتابعة")
                            .font(.subheadline)
                            .foregroundColor(.secondaryText)
                    }
                    .padding(.top, 60)

                    // Form Card
                    VStack(spacing: 20) {
                        if isSignUp {
                            ModernTextField(
                                icon: "person.fill",
                                placeholder: "الاسم الكامل",
                                text: $fullName
                            )
                        }

                        ModernTextField(
                            icon: "envelope.fill",
                            placeholder: "البريد الإلكتروني",
                            text: $email,
                            keyboardType: .emailAddress
                        )

                        ModernTextField(
                            icon: "lock.fill",
                            placeholder: "كلمة المرور",
                            text: $password,
                            isSecure: true
                        )

                        if let errorMessage = authManager.errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                            .padding(.horizontal)
                        }

                        // Primary Action Button
                        Button(action: {
                            isLoading = true
                            Task {
                                if isSignUp {
                                    await authManager.signUp(email: email, password: password, fullName: fullName)
                                } else {
                                    await authManager.signIn(email: email, password: password)
                                }
                                isLoading = false
                            }
                        }) {
                            HStack(spacing: 12) {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: isSignUp ? "person.badge.plus" : "arrow.right.circle.fill")
                                    Text(isSignUp ? "إنشاء الحساب" : "تسجيل الدخول")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [.accent, .premium],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(14)
                            .shadow(color: Color.accent.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .disabled(isLoading)
                    }
                    .padding(24)
                    .background(Color.cardBackground)
                    .cornerRadius(24)
                    .shadow(color: Color.black.opacity(0.05), radius: 20, x: 0, y: 10)
                    .padding(.horizontal, 20)

                    // Toggle Sign Up/Sign In
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isSignUp.toggle()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Text(isSignUp ? "لديك حساب بالفعل؟" : "ليس لديك حساب؟")
                                .foregroundColor(.secondaryText)
                            Text(isSignUp ? "سجل الدخول" : "سجل الآن")
                                .fontWeight(.semibold)
                                .foregroundColor(.accent)
                        }
                        .font(.subheadline)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}

// Modern Text Field Component
struct ModernTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(isFocused ? .accent : .secondaryText)
                .frame(width: 20)

            if isSecure {
                SecureField(placeholder, text: $text)
                    .focused($isFocused)
                    .autocapitalization(.none)
            } else {
                TextField(placeholder, text: $text)
                    .focused($isFocused)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.secondaryBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isFocused ? Color.accent : Color.clear, lineWidth: 2)
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}
