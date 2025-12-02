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
            // Deep black background
            Color.primaryBackground
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 40) {
                    Spacer()
                        .frame(height: 60)

                    // Premium Logo Area
                    VStack(spacing: 20) {
                        // Glowing icon
                        ZStack {
                            Circle()
                                .fill(Color.accentDim)
                                .frame(width: 120, height: 120)
                                .blur(radius: 30)

                            Image(systemName: "graduationcap.fill")
                                .font(.system(size: 50, weight: .light))
                                .foregroundColor(.accent)
                        }

                        VStack(spacing: 8) {
                            Text(isSignUp ? "إنشاء حساب" : "تسجيل الدخول")
                                .font(.system(size: 36, weight: .bold, design: .default))
                                .foregroundColor(.primaryText)

                            Text(isSignUp ? "انضم إلى المنصة الآن" : "مرحباً بعودتك")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(.secondaryText)
                        }
                    }
                    .padding(.bottom, 20)

                    // Form Container
                    VStack(spacing: 24) {
                        if isSignUp {
                            PremiumTextField(
                                icon: "person.fill",
                                placeholder: "الاسم الكامل",
                                text: $fullName
                            )
                        }

                        PremiumTextField(
                            icon: "envelope.fill",
                            placeholder: "البريد الإلكتروني",
                            text: $email,
                            keyboardType: .emailAddress
                        )

                        PremiumTextField(
                            icon: "lock.fill",
                            placeholder: "كلمة المرور",
                            text: $password,
                            isSecure: true
                        )

                        // Error Message
                        if let errorMessage = authManager.errorMessage {
                            HStack(spacing: 10) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.danger)
                                Text(errorMessage)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.danger)
                                Spacer()
                            }
                            .padding(.horizontal, 6)
                        }

                        // Primary Button
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
                                        .progressViewStyle(CircularProgressViewStyle(tint: .primaryBackground))
                                        .scaleEffect(1.1)
                                } else {
                                    Text(isSignUp ? "إنشاء الحساب" : "دخول")
                                        .font(.system(size: 17, weight: .semibold))

                                    Image(systemName: "arrow.left")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.accent)
                            .foregroundColor(.primaryBackground)
                            .cornerRadius(16)
                            .shadow(color: Color.accentGlow, radius: 20, x: 0, y: 8)
                        }
                        .disabled(isLoading || email.isEmpty || password.isEmpty || (isSignUp && fullName.isEmpty))
                        .opacity((isLoading || email.isEmpty || password.isEmpty || (isSignUp && fullName.isEmpty)) ? 0.5 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isLoading)
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 28)

                    // Terms & Privacy Consent
                    VStack(spacing: 12) {
                        Text("بالمتابعة، أنت توافق على")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.secondaryText)

                        HStack(spacing: 6) {
                            Button(action: {
                                if let url = URL(string: "https://ecomclub.net/terms") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                Text("شروط الاستخدام")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.accent)
                                    .underline()
                            }

                            Text("و")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.secondaryText)

                            Button(action: {
                                if let url = URL(string: "https://ecomclub.net/privacy-policy") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                Text("سياسة الخصوصية")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.accent)
                                    .underline()
                            }
                        }
                    }
                    .padding(.top, 20)

                    // Toggle Sign Up/Sign In
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isSignUp.toggle()
                        }
                    }) {
                        HStack(spacing: 6) {
                            Text(isSignUp ? "لديك حساب؟" : "حساب جديد؟")
                                .foregroundColor(.secondaryText)
                            Text(isSignUp ? "دخول" : "سجّل الآن")
                                .fontWeight(.semibold)
                                .foregroundColor(.accent)
                        }
                        .font(.system(size: 15))
                    }
                    .padding(.top, 12)

                    Spacer()
                        .frame(height: 60)
                }
                .frame(maxWidth: 500)
                .frame(maxWidth: .infinity)
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}

// Premium Text Field Component
struct PremiumTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isFocused ? .accent : .tertiaryText)
                    .frame(width: 22)

                ZStack(alignment: .leading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .foregroundColor(.tertiaryText)
                            .font(.system(size: 16))
                    }

                    if isSecure {
                        SecureField("", text: $text)
                            .focused($isFocused)
                            .autocapitalization(.none)
                            .foregroundColor(.primaryText)
                            .font(.system(size: 16, weight: .medium))
                    } else {
                        TextField("", text: $text)
                            .focused($isFocused)
                            .keyboardType(keyboardType)
                            .autocapitalization(.none)
                            .foregroundColor(.primaryText)
                            .font(.system(size: 16, weight: .medium))
                    }
                }
            }
            .padding(.horizontal, 20)
            .frame(height: 56)
            .background(Color.inputBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(isFocused ? Color.accent : Color.clear, lineWidth: 1.5)
            )
            .animation(.easeInOut(duration: 0.25), value: isFocused)
        }
    }
}
