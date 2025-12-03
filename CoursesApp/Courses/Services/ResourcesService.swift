import Foundation
import Supabase
import PostgREST

@MainActor
class ResourcesService {
    private let supabase = SupabaseClient.shared.client

    func fetchResources(category: ResourceCategory? = nil) async throws -> [Resource] {
        let response: PostgrestResponse<Data>

        if let category = category {
            response = try await supabase
                .from("resources")
                .select()
                .eq("is_active", value: true)
                .eq("category", value: category.rawValue)
                .order("created_at", ascending: false)
                .execute()
        } else {
            response = try await supabase
                .from("resources")
                .select()
                .eq("is_active", value: true)
                .order("created_at", ascending: false)
                .execute()
        }

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
