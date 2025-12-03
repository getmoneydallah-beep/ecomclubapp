import Foundation
import Supabase

@MainActor
class UserStatsService {
    private let supabase = SupabaseClient.shared.client

    func fetchUserStats(userId: UUID) async throws -> UserStats {
        // Fetch completed courses count
        let enrollmentsResponse = try await supabase
            .from("course_enrollments")
            .select("id")
            .eq("user_id", value: userId.uuidString)
            .execute()

        let enrollmentsDecoder = JSONDecoder()
        let enrollments = try enrollmentsDecoder.decode([[String: String]].self, from: enrollmentsResponse.data)
        let completedCourses = enrollments.count

        // Fetch all user challenges and filter active ones
        let challengesResponse = try await supabase
            .from("user_challenges")
            .select("id, completed_at")
            .eq("user_id", value: userId.uuidString)
            .execute()

        struct ChallengeRow: Codable {
            let id: String
            let completed_at: String?
        }

        let allChallenges = try JSONDecoder().decode([ChallengeRow].self, from: challengesResponse.data)
        let activeChallengesCount = allChallenges.filter { $0.completed_at == nil }.count

        // Fetch community wins count
        let winsResponse = try await supabase
            .from("community_wins")
            .select("id")
            .eq("user_id", value: userId.uuidString)
            .eq("is_approved", value: true)
            .execute()

        let winsDecoder = JSONDecoder()
        let wins = try winsDecoder.decode([[String: String]].self, from: winsResponse.data)
        let communityWinsCount = wins.count

        // For now, days streak is 0 (would need activity tracking table)
        let daysStreak = 0

        return UserStats(
            completedCourses: completedCourses,
            activeChallenges: activeChallengesCount,
            communityWins: communityWinsCount,
            daysStreak: daysStreak
        )
    }
}
