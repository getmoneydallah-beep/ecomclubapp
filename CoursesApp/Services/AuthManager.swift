import Foundation
import Supabase
import Combine

@MainActor
class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var errorMessage: String?

    private let supabase = SupabaseClient.shared.client

    init() {
        checkAuthStatus()
    }

    func checkAuthStatus() {
        Task {
            do {
                let session = try await supabase.auth.session
                self.isAuthenticated = true
                self.currentUser = session.user
            } catch {
                self.isAuthenticated = false
                self.currentUser = nil
            }
        }
    }

    func signIn(email: String, password: String) async {
        do {
            let session = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            self.isAuthenticated = true
            self.currentUser = session.user
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func signUp(email: String, password: String, fullName: String) async {
        do {
            let session = try await supabase.auth.signUp(
                email: email,
                password: password
            )

            // Update profile with full name
            let userId = session.user.id
            try await supabase
                .from("profiles")
                .update(["full_name": fullName])
                .eq("id", value: userId.uuidString)
                .execute()

            self.isAuthenticated = true
            self.currentUser = session.user
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func signOut() async {
        do {
            try await supabase.auth.signOut()
            self.isAuthenticated = false
            self.currentUser = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func deleteAccount(userId: UUID) async throws {
        // Delete user data from profiles table
        try await supabase
            .from("profiles")
            .delete()
            .eq("id", value: userId.uuidString)
            .execute()

        // Delete user enrollments
        try await supabase
            .from("course_enrollments")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .execute()

        // Delete user subscriptions
        try await supabase
            .from("subscriptions")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .execute()

        // Sign out and delete auth user
        try await supabase.auth.signOut()

        // Note: Actual user deletion from auth.users should be handled server-side
        // via Supabase Edge Function or Database Trigger for security

        self.isAuthenticated = false
        self.currentUser = nil
    }
}
