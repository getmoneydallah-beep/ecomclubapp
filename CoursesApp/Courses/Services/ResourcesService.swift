import Foundation
import Supabase

@MainActor
class ResourcesService {
    private let supabase = SupabaseClient.shared.client

    func fetchResources(category: ResourceCategory? = nil) async throws -> [Resource] {
        var query = supabase
            .from("resources")
            .select()
            .eq("is_active", value: true)
            .order("created_at", ascending: false)

        if let category = category {
            query = query.eq("category", value: category.rawValue)
        }

        let response = try await query.execute()

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let resources = try decoder.decode([Resource].self, from: response.data)
        return resources
    }

    func fetchFreeResources() async throws -> [Resource] {
        let response = try await supabase
            .from("resources")
            .select()
            .eq("is_active", value: true)
            .eq("is_free", value: true)
            .order("created_at", ascending: false)
            .execute()

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let resources = try decoder.decode([Resource].self, from: response.data)
        return resources
    }

    func fetchResourceById(_ id: UUID) async throws -> Resource {
        let response = try await supabase
            .from("resources")
            .select()
            .eq("id", value: id.uuidString)
            .single()
            .execute()

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let resource = try decoder.decode(Resource.self, from: response.data)
        return resource
    }
}
