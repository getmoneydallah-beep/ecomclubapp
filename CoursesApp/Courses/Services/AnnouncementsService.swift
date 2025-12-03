import Foundation
import Supabase

@MainActor
class AnnouncementsService {
    private let supabase = SupabaseClient.shared.client

    func fetchActiveAnnouncements() async throws -> [Announcement] {
        let response = try await supabase
            .from("announcements")
            .select()
            .eq("is_active", value: true)
            .order("created_at", ascending: false)
            .execute()

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let allAnnouncements = try decoder.decode([Announcement].self, from: response.data)

        // Filter announcements that haven't expired
        let now = Date()
        let activeAnnouncements = allAnnouncements.filter { announcement in
            if let expiresAt = announcement.expiresAt {
                return expiresAt > now
            }
            return true // No expiry date means it's always active
        }

        return activeAnnouncements
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
