import Foundation
import Supabase

@MainActor
class LiveEventsService {
    private let supabase = SupabaseClient.shared.client

    func fetchUpcomingEvents() async throws -> [LiveEvent] {
        let now = ISO8601DateFormatter().string(from: Date())

        let response = try await supabase
            .from("live_events")
            .select()
            .eq("is_active", value: true)
            .gte("event_date", value: now)
            .order("event_date", ascending: true)
            .execute()

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let events = try decoder.decode([LiveEvent].self, from: response.data)
        return events
    }

    func fetchEventById(_ id: UUID) async throws -> LiveEvent {
        let response = try await supabase
            .from("live_events")
            .select()
            .eq("id", value: id.uuidString)
            .single()
            .execute()

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let event = try decoder.decode(LiveEvent.self, from: response.data)
        return event
    }

    func fetchPastEvents(limit: Int = 10) async throws -> [LiveEvent] {
        let now = ISO8601DateFormatter().string(from: Date())

        let response = try await supabase
            .from("live_events")
            .select()
            .eq("is_active", value: true)
            .lt("event_date", value: now)
            .order("event_date", ascending: false)
            .limit(limit)
            .execute()

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let events = try decoder.decode([LiveEvent].self, from: response.data)
        return events
    }
}
