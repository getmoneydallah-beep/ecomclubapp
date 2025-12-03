import Foundation
import Supabase

@MainActor
class CommunityService {
    private let supabase = SupabaseClient.shared.client

    func fetchApprovedWins(limit: Int = 20) async throws -> [CommunityWin] {
        let response = try await supabase
            .from("community_wins")
            .select("""
                *,
                profiles!inner(full_name, avatar_url),
                reactions_count:community_reactions(count),
                comments_count:community_comments(count)
            """)
            .eq("is_approved", value: true)
            .order("created_at", ascending: false)
            .limit(limit)
            .execute()

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let wins = try decoder.decode([CommunityWin].self, from: response.data)
        return wins
    }

    func createWin(userId: UUID, titleAr: String, descriptionAr: String?, winType: WinType) async throws {
        let newWin: [String: Any?] = [
            "user_id": userId.uuidString,
            "title_ar": titleAr,
            "description_ar": descriptionAr,
            "win_type": winType.rawValue,
            "is_approved": false
        ]

        _ = try await supabase
            .from("community_wins")
            .insert(newWin)
            .execute()
    }

    func fetchComments(winId: UUID) async throws -> [CommunityComment] {
        let response = try await supabase
            .from("community_comments")
            .select("""
                *,
                profiles!inner(full_name, avatar_url)
            """)
            .eq("win_id", value: winId.uuidString)
            .order("created_at", ascending: true)
            .execute()

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let comments = try decoder.decode([CommunityComment].self, from: response.data)
        return comments
    }

    func addComment(winId: UUID, userId: UUID, content: String) async throws {
        let newComment: [String: Any] = [
            "win_id": winId.uuidString,
            "user_id": userId.uuidString,
            "content": content
        ]

        _ = try await supabase
            .from("community_comments")
            .insert(newComment)
            .execute()
    }

    func addReaction(winId: UUID, userId: UUID, reactionType: String = "like") async throws {
        let newReaction: [String: Any] = [
            "win_id": winId.uuidString,
            "user_id": userId.uuidString,
            "reaction_type": reactionType
        ]

        _ = try await supabase
            .from("community_reactions")
            .insert(newReaction)
            .execute()
    }

    func removeReaction(winId: UUID, userId: UUID) async throws {
        _ = try await supabase
            .from("community_reactions")
            .delete()
            .eq("win_id", value: winId.uuidString)
            .eq("user_id", value: userId.uuidString)
            .execute()
    }

    func checkUserReaction(winId: UUID, userId: UUID) async throws -> Bool {
        let response = try await supabase
            .from("community_reactions")
            .select("id")
            .eq("win_id", value: winId.uuidString)
            .eq("user_id", value: userId.uuidString)
            .execute()

        let decoder = JSONDecoder()
        let reactions = try decoder.decode([CommunityReaction].self, from: response.data)
        return !reactions.isEmpty
    }
}
