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
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        titleAr = try container.decode(String.self, forKey: .titleAr)
        descriptionAr = try container.decodeIfPresent(String.self, forKey: .descriptionAr)
        thumbnailUrl = try container.decodeIfPresent(String.self, forKey: .thumbnailUrl)
        price = try container.decodeIfPresent(Double.self, forKey: .price)
        isFree = try container.decode(Bool.self, forKey: .isFree)
        includedInSubscription = try container.decode(Bool.self, forKey: .includedInSubscription)
        published = try container.decode(Bool.self, forKey: .published)
        difficultyLevel = try container.decodeIfPresent(String.self, forKey: .difficultyLevel)

        // Handle duration_hours as either Int or Double
        if let intValue = try? container.decode(Int.self, forKey: .durationHours) {
            durationHours = Double(intValue)
        } else {
            durationHours = try container.decodeIfPresent(Double.self, forKey: .durationHours)
        }
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

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case courseId = "course_id"
    }
}

struct Subscription: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let status: String

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case status
    }
}
