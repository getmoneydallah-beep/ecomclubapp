import Foundation

struct Course: Codable, Identifiable {
    let id: UUID
    let titleAr: String
    let descriptionAr: String?
    let thumbnailUrl: String?
    let price: Double?
    let isFree: Bool
    let includedInSubscription: Bool
    let published: Bool
    let difficultyLevel: String?
    let durationHours: Double?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case titleAr = "title_ar"
        case descriptionAr = "description_ar"
        case thumbnailUrl = "thumbnail_url"
        case price
        case isFree = "is_free"
        case includedInSubscription = "included_in_subscription"
        case published
        case difficultyLevel = "difficulty_level"
        case durationHours = "duration_hours"
        case createdAt = "created_at"
    }
}

struct CourseSection: Codable, Identifiable {
    let id: UUID
    let courseId: UUID
    let titleAr: String
    let descriptionAr: String?
    let orderIndex: Int
    var lessons: [CourseLesson]?

    enum CodingKeys: String, CodingKey {
        case id
        case courseId = "course_id"
        case titleAr = "title_ar"
        case descriptionAr = "description_ar"
        case orderIndex = "order_index"
        case lessons
    }
}

struct CourseLesson: Codable, Identifiable {
    let id: UUID
    let sectionId: UUID
    let titleAr: String
    let descriptionAr: String?
    let videoUrl: String?
    let videoDuration: Int?
    let isFreePreview: Bool
    let orderIndex: Int

    enum CodingKeys: String, CodingKey {
        case id
        case sectionId = "section_id"
        case titleAr = "title_ar"
        case descriptionAr = "description_ar"
        case videoUrl = "video_url"
        case videoDuration = "video_duration"
        case isFreePreview = "is_free_preview"
        case orderIndex = "order_index"
    }
}

struct CourseEnrollment: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let courseId: UUID
    let enrolledAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case courseId = "course_id"
        case enrolledAt = "enrolled_at"
    }
}

struct Subscription: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let status: String
    let currentPeriodEnd: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case status
        case currentPeriodEnd = "current_period_end"
    }
}
