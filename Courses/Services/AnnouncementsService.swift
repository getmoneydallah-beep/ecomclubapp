import Foundation
import Supabase

@MainActor
class AnnouncementsService {
    private let supabase = SupabaseClient.shared.client

    func fetchActiveAnnouncements() async throws -> [Announcement] {
        let now = ISO8601DateFormatter().string(from: Date())

        let response = try await supabase
            .from("announcements")
            .select()
            .eq("is_active", value: true)
            .or("expires_at.is.null,expires_at.gte.\(now)")
            .order("created_at", ascending: false)
            .execute()

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let announcements = try decoder.decode([Announcement].self, from: response.data)
        return announcements
    }

    func fetchAnnouncementById(_ id: UUID) async throws -> Announcement {
        let response = try await supabase
            .from("announcements")
            .select()
            .eq("id", value: id.uuidString)
            .single()
            .execute()

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let announcement = try decoder.decode(Announcement.self, from: response.data)
        return announcement
    }
}
