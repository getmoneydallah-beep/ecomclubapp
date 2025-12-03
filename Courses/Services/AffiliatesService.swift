import Foundation
import Supabase

@MainActor
class AffiliatesService {
    private let supabase = SupabaseClient.shared.client

    func fetchUserAffiliate(userId: UUID) async throws -> Affiliate {
        let response = try await supabase
            .from("affiliates")
            .select()
            .eq("user_id", value: userId.uuidString)
            .single()
            .execute()

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let affiliate = try decoder.decode(Affiliate.self, from: response.data)
        return affiliate
    }

    func fetchAffiliateStats(userId: UUID) async throws -> (totalReferrals: Int, totalEarnings: Double) {
        let affiliate = try await fetchUserAffiliate(userId: userId)
        return (
            totalReferrals: affiliate.totalReferrals ?? 0,
            totalEarnings: affiliate.totalEarnings ?? 0.0
        )
    }
}
