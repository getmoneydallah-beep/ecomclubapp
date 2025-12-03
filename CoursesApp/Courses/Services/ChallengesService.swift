import Foundation
import Supabase

@MainActor
class ChallengesService {
    private let supabase = SupabaseClient.shared.client

    func fetchActiveChallenges() async throws -> [Challenge] {
        let response = try await supabase
            .from("challenges")
            .select("""
                *,
                tasks:challenge_tasks(*)
            """)
            .eq("is_active", value: true)
            .order("created_at", ascending: false)
            .execute()

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let challenges = try decoder.decode([Challenge].self, from: response.data)
        return challenges
    }

    func fetchUserChallenges(userId: UUID) async throws -> [UserChallenge] {
        let response = try await supabase
            .from("user_challenges")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("started_at", ascending: false)
            .execute()

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let userChallenges = try decoder.decode([UserChallenge].self, from: response.data)
        return userChallenges
    }

    func startChallenge(userId: UUID, challengeId: UUID) async throws {
        struct NewUserChallenge: Encodable {
            let user_id: String
            let challenge_id: String
            let progress: Int
        }

        let newUserChallenge = NewUserChallenge(
            user_id: userId.uuidString,
            challenge_id: challengeId.uuidString,
            progress: 0
        )

        _ = try await supabase
            .from("user_challenges")
            .insert(newUserChallenge)
            .execute()
    }

    func completeTask(userChallengeId: UUID, taskId: UUID) async throws {
        struct NewTaskCompletion: Encodable {
            let user_challenge_id: String
            let task_id: String
        }

        let newTaskCompletion = NewTaskCompletion(
            user_challenge_id: userChallengeId.uuidString,
            task_id: taskId.uuidString
        )

        _ = try await supabase
            .from("user_challenge_tasks")
            .insert(newTaskCompletion)
            .execute()
    }

    func fetchUserChallengeTasks(userChallengeId: UUID) async throws -> [UserChallengeTask] {
        let response = try await supabase
            .from("user_challenge_tasks")
            .select()
            .eq("user_challenge_id", value: userChallengeId.uuidString)
            .execute()

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let tasks = try decoder.decode([UserChallengeTask].self, from: response.data)
        return tasks
    }
}
