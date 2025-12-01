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

        let courses = try JSONDecoder().decode([Course].self, from: response.data)
        return courses
    }

    func fetchCourseSections(courseId: UUID) async throws -> [CourseSection] {
        let response = try await supabase
            .from("course_sections")
            .select("*, course_lessons(*)")
            .eq("course_id", value: courseId.uuidString)
            .order("order_index")
            .execute()

        let sections = try JSONDecoder().decode([CourseSection].self, from: response.data)
        return sections
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
