import Foundation
import Supabase

@MainActor
class SubscriptionManager: ObservableObject {
    @Published var hasActiveSubscription: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let supabase = SupabaseClient.shared.client

    func checkSubscriptionStatus(userId: UUID) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await supabase
                .from("subscriptions")
                .select("status")
                .eq("user_id", value: userId.uuidString)
                .eq("status", value: "active")
                .execute()

            let decoder = JSONDecoder()
            let subscriptions = try decoder.decode([[String: String]].self, from: response.data)

            hasActiveSubscription = !subscriptions.isEmpty
        } catch {
            errorMessage = "فشل في التحقق من حالة الاشتراك: \(error.localizedDescription)"
            hasActiveSubscription = false
        }

        isLoading = false
    }

    func hasAccess(for resource: Resource) -> Bool {
        return resource.isFree || hasActiveSubscription
    }

    func hasAccessToCommunityPosting() -> Bool {
        return hasActiveSubscription
    }

    func hasAccessToLiveEvent() -> Bool {
        return hasActiveSubscription
    }

    func hasAccessToCourse(isFree: Bool) -> Bool {
        return isFree || hasActiveSubscription
    }
}
