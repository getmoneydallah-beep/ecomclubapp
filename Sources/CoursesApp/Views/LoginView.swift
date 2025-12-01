import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var fullName = ""
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(isSignUp ? "إنشاء حساب" : "تسجيل الدخول")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 50)

                VStack(spacing: 15) {
                    if isSignUp {
                        TextField("الاسم الكامل", text: $fullName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                    }

                    TextField("البريد الإلكتروني", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(.horizontal)

                    SecureField("كلمة المرور", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                }
                .padding(.top, 20)

                if let errorMessage = authManager.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }

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
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text(isSignUp ? "إنشاء حساب" : "تسجيل الدخول")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .disabled(isLoading)

                Button(action: {
                    isSignUp.toggle()
                }) {
                    Text(isSignUp ? "لديك حساب بالفعل؟ سجل الدخول" : "ليس لديك حساب؟ سجل الآن")
                        .foregroundColor(.blue)
                }
                .padding(.top, 10)

                Spacer()
            }
            .environment(\.layoutDirection, .rightToLeft)
        }
    }
}
