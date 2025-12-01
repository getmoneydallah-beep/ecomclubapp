import Foundation
import Supabase

class CoursesService {
    private let supabase = SupabaseClient.shared.client

    func fetchCourses() async throws -> [Course] {
        let response = try await supabase
            .from("courses")
            .select()
            .eq("published", value: true)
            .execute()

        // Debug: Print raw response
        if let jsonString = String(data: response.data, encoding: .utf8) {
            print("📦 Raw courses response:", jsonString)
        }

        do {
            let courses = try JSONDecoder().decode([Course].self, from: response.data)
            return courses
        } catch {
            print("❌ Decoding error:", error)
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("Missing key '\(key.stringValue)' - \(context.debugDescription)")
                case .typeMismatch(let type, let context):
                    print("Type mismatch for type '\(type)' - \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    print("Value not found for type '\(type)' - \(context.debugDescription)")
                case .dataCorrupted(let context):
                    print("Data corrupted - \(context.debugDescription)")
                @unknown default:
                    print("Unknown decoding error")
                }
            }
            throw error
        }
    }

    func fetchCourseSections(courseId: UUID) async throws -> [CourseSection] {
        let response = try await supabase
            .from("course_sections")
            .select("*, course_lessons(*)")
            .eq("course_id", value: courseId.uuidString)
            .order("order_index")
            .execute()

        // Debug: Print raw response
        if let jsonString = String(data: response.data, encoding: .utf8) {
            print("📦 Raw sections response for course \(courseId):", jsonString)
        }

        do {
            let sections = try JSONDecoder().decode([CourseSection].self, from: response.data)
            print("✅ Successfully decoded \(sections.count) sections")
            for section in sections {
                print("  Section: \(section.titleAr) - Lessons: \(section.lessons?.count ?? 0)")
            }
            return sections
        } catch {
            print("❌ Sections decoding error:", error)
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("Missing key '\(key.stringValue)' - \(context.debugDescription)")
                case .typeMismatch(let type, let context):
                    print("Type mismatch for type '\(type)' - \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    print("Value not found for type '\(type)' - \(context.debugDescription)")
                case .dataCorrupted(let context):
                    print("Data corrupted - \(context.debugDescription)")
                @unknown default:
                    print("Unknown decoding error")
                }
            }
            throw error
        }
    }

    func checkEnrollment(courseId: UUID, userId: UUID) async throws -> Bool {
        let response = try await supabase
            .from("course_enrollments")
            .select()
            .eq("course_id", value: courseId.uuidString)
            .eq("user_id", value: userId.uuidString)
            .execute()

        let enrollments = try JSONDecoder().decode([CourseEnrollment].self, from: response.data)
        return !enrollments.isEmpty
    }

    func checkActiveSubscription(userId: UUID) async throws -> Bool {
        let response = try await supabase
            .from("subscriptions")
            .select()
            .eq("user_id", value: userId.uuidString)
            .eq("status", value: "active")
            .execute()

        let subscriptions = try JSONDecoder().decode([Subscription].self, from: response.data)
        return !subscriptions.isEmpty
    }
}
