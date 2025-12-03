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

        // Fetch active challenges count
        let challengesResponse = try await supabase
            .from("user_challenges")
            .select("id")
            .eq("user_id", value: userId.uuidString)
            .isNull("completed_at")
            .execute()

        let challengesDecoder = JSONDecoder()
        let activeChallenges = try challengesDecoder.decode([[String: String]].self, from: challengesResponse.data)
        let activeChallengesCount = activeChallenges.count

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
