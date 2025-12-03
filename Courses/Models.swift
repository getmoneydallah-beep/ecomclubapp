import Foundation

// MARK: - Announcement Models
struct Announcement: Codable, Identifiable {
    let id: UUID
    let titleAr: String
    let contentAr: String
    let type: AnnouncementType
    let linkUrl: String?
    let linkTextAr: String?
    let isActive: Bool
    let expiresAt: Date?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case titleAr = "title_ar"
        case contentAr = "content_ar"
        case type
        case linkUrl = "link_url"
        case linkTextAr = "link_text_ar"
        case isActive = "is_active"
        case expiresAt = "expires_at"
        case createdAt = "created_at"
    }
}

enum AnnouncementType: String, Codable {
    case general
    case newCourse = "new_course"
    case challenge
    case liveEvent = "live_event"
}

// MARK: - Challenge Models
struct Challenge: Codable, Identifiable {
    let id: UUID
    let titleAr: String
    let descriptionAr: String
    let durationDays: Int
    let thumbnailUrl: String?
    let isActive: Bool
    let createdAt: Date
    let tasks: [ChallengeTask]?

    enum CodingKeys: String, CodingKey {
        case id
        case titleAr = "title_ar"
        case descriptionAr = "description_ar"
        case durationDays = "duration_days"
        case thumbnailUrl = "thumbnail_url"
        case isActive = "is_active"
        case createdAt = "created_at"
        case tasks
    }
}

struct ChallengeTask: Codable, Identifiable {
    let id: UUID
    let challengeId: UUID
    let titleAr: String
    let descriptionAr: String?
    let orderIndex: Int
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case challengeId = "challenge_id"
        case titleAr = "title_ar"
        case descriptionAr = "description_ar"
        case orderIndex = "order_index"
        case createdAt = "created_at"
    }
}

struct UserChallenge: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let challengeId: UUID
    let startedAt: Date
    let completedAt: Date?
    let progress: Int

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case challengeId = "challenge_id"
        case startedAt = "started_at"
        case completedAt = "completed_at"
        case progress
    }
}

struct UserChallengeTask: Codable, Identifiable {
    let id: UUID
    let userChallengeId: UUID
    let taskId: UUID
    let completedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userChallengeId = "user_challenge_id"
        case taskId = "task_id"
        case completedAt = "completed_at"
    }
}

// MARK: - Live Event Models
struct LiveEvent: Codable, Identifiable {
    let id: UUID
    let titleAr: String
    let descriptionAr: String
    let eventDate: Date
    let meetingUrl: String?
    let thumbnailUrl: String?
    let isActive: Bool
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case titleAr = "title_ar"
        case descriptionAr = "description_ar"
        case eventDate = "event_date"
        case meetingUrl = "meeting_url"
        case thumbnailUrl = "thumbnail_url"
        case isActive = "is_active"
        case createdAt = "created_at"
    }
}

// MARK: - Community Win Models
struct CommunityWin: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let titleAr: String
    let descriptionAr: String?
    let winType: WinType
    let isApproved: Bool
    let createdAt: Date
    let profiles: UserProfile?
    let reactionsCount: Int?
    let commentsCount: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case titleAr = "title_ar"
        case descriptionAr = "description_ar"
        case winType = "win_type"
        case isApproved = "is_approved"
        case createdAt = "created_at"
        case profiles
        case reactionsCount = "reactions_count"
        case commentsCount = "comments_count"
    }
}

enum WinType: String, Codable, CaseIterable {
    case firstSale = "first_sale"
    case newStore = "new_store"
    case productLaunch = "product_launch"
    case other

    var displayName: String {
        switch self {
        case .firstSale: return "أول بيعة"
        case .newStore: return "متجر جديد"
        case .productLaunch: return "إطلاق منتج"
        case .other: return "آخر"
        }
    }
}

struct UserProfile: Codable {
    let fullName: String
    let avatarUrl: String?

    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case avatarUrl = "avatar_url"
    }
}

struct CommunityComment: Codable, Identifiable {
    let id: UUID
    let winId: UUID
    let userId: UUID
    let content: String
    let createdAt: Date
    let profiles: UserProfile?

    enum CodingKeys: String, CodingKey {
        case id
        case winId = "win_id"
        case userId = "user_id"
        case content
        case createdAt = "created_at"
        case profiles
    }
}

struct CommunityReaction: Codable, Identifiable {
    let id: UUID
    let winId: UUID
    let userId: UUID
    let reactionType: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case winId = "win_id"
        case userId = "user_id"
        case reactionType = "reaction_type"
        case createdAt = "created_at"
    }
}

// MARK: - Resource Models
struct Resource: Codable, Identifiable {
    let id: UUID
    let titleAr: String
    let descriptionAr: String
    let category: ResourceCategory
    let fileUrl: String
    let fileType: String
    let isFree: Bool
    let isActive: Bool
    let createdAt: Date
    let thumbnailUrl: String?

    enum CodingKeys: String, CodingKey {
        case id
        case titleAr = "title_ar"
        case descriptionAr = "description_ar"
        case category
        case fileUrl = "file_url"
        case fileType = "file_type"
        case isFree = "is_free"
        case isActive = "is_active"
        case createdAt = "created_at"
        case thumbnailUrl = "thumbnail_url"
    }
}

enum ResourceCategory: String, Codable, CaseIterable {
    case templates
    case tools
    case guides
    case checklists
    case aiPrompts = "ai_prompts"

    var displayName: String {
        switch self {
        case .templates: return "قوالب"
        case .tools: return "أدوات"
        case .guides: return "أدلة"
        case .checklists: return "قوائم تحقق"
        case .aiPrompts: return "أوامر الذكاء الاصطناعي"
        }
    }
}

// MARK: - Affiliate Models
struct Affiliate: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let referralCode: String
    let totalReferrals: Int?
    let totalEarnings: Double?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case referralCode = "referral_code"
        case totalReferrals = "total_referrals"
        case totalEarnings = "total_earnings"
        case createdAt = "created_at"
    }
}

// MARK: - User Stats Models
struct UserStats: Codable {
    let completedCourses: Int
    let activeChallenges: Int
    let communityWins: Int
    let daysStreak: Int

    enum CodingKeys: String, CodingKey {
        case completedCourses = "completed_courses"
        case activeChallenges = "active_challenges"
        case communityWins = "community_wins"
        case daysStreak = "days_streak"
    }
}

// MARK: - Track Types (for courses)
enum CourseTrack: String, Codable, CaseIterable {
    case beginnerRoadmap = "beginner_roadmap"
    case launchRoadmap = "launch_roadmap"
    case scalingRoadmap = "scaling_roadmap"
    case paidAds = "paid_ads"
    case aiAutomation = "ai_automation"

    var displayName: String {
        switch self {
        case .beginnerRoadmap: return "مسار المبتدئين"
        case .launchRoadmap: return "مسار الإطلاق"
        case .scalingRoadmap: return "مسار التوسع"
        case .paidAds: return "الإعلانات المدفوعة"
        case .aiAutomation: return "الذكاء الاصطناعي والأتمتة"
        }
    }
}
