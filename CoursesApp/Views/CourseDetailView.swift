import SwiftUI

struct CourseDetailView: View {
    let course: Course
    @EnvironmentObject var authManager: AuthManager
    @State private var sections: [CourseSection] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var isEnrolled = false
    @State private var hasActiveSubscription = false

    private let coursesService = CoursesService()

    var body: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Hero Image with gradient
                    ZStack(alignment: .bottomLeading) {
                        if let thumbnailUrl = course.thumbnailUrl {
                            AsyncImage(url: URL(string: thumbnailUrl)) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                case .empty, .failure:
                                    Rectangle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.accentDim, Color.tertiaryBackground],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(height: 220)
                            .clipped()
                        }

                        // Dark gradient overlay
                        LinearGradient(
                            colors: [.clear, Color.primaryBackground.opacity(0.9)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 220)

                        // Status badge
                        HStack {
                            if course.isFree {
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.seal.fill")
                                        .font(.system(size: 12))
                                    Text("مجاني")
                                        .font(.system(size: 13, weight: .bold))
                                }
                                .foregroundColor(.primaryBackground)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color.success)
                                .cornerRadius(20)
                            } else if let price = course.price, price > 0 {
                                HStack(spacing: 6) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 12))
                                    Text("\(String(format: "%.0f", price)) ريال")
                                        .font(.system(size: 13, weight: .bold))
                                }
                                .foregroundColor(.primaryBackground)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color.accent)
                                .cornerRadius(20)
                            }
                            Spacer()
                        }
                        .padding(20)
                    }

                    // Content Card
                    VStack(alignment: .leading, spacing: 20) {
                        // Title
                        Text(course.titleAr)
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.primaryText)
                            .multilineTextAlignment(.leading)

                        // Description
                        if let description = course.descriptionAr {
                            Text(description)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.secondaryText)
                                .multilineTextAlignment(.leading)
                                .lineSpacing(3)
                        }

                        // Metadata pills
                        HStack(spacing: 12) {
                            if let difficulty = course.difficultyLevel {
                                PillBadge(
                                    icon: "chart.bar.fill",
                                    text: difficulty,
                                    color: .premium
                                )
                            }

                            if let duration = course.durationHours {
                                PillBadge(
                                    icon: "clock.fill",
                                    text: "\(String(format: "%.0f", duration)) ساعة",
                                    color: .accent
                                )
                            }
                        }

                        // Divider
                        Rectangle()
                            .fill(Color.tertiaryBackground)
                            .frame(height: 1)
                            .padding(.vertical, 4)

                        // Course Content Header
                        Text("محتوى الدورة")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primaryText)

                        // Loading / Error / Content
                        if isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .accent))
                                    .scaleEffect(1.2)
                                Spacer()
                            }
                            .padding(.vertical, 40)
                        } else if let error = errorMessage {
                            VStack(spacing: 16) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 40, weight: .light))
                                    .foregroundColor(.danger)
                                Text(error)
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.secondaryText)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.vertical, 30)
                        } else {
                            VStack(spacing: 14) {
                                ForEach(sections) { section in
                                    PremiumSectionView(
                                        section: section,
                                        course: course,
                                        isEnrolled: isEnrolled,
                                        hasActiveSubscription: hasActiveSubscription
                                    )
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(Color.primaryBackground)
                    .offset(y: -30)
                }
            }
            .ignoresSafeArea(edges: .top)
        }
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.layoutDirection, .rightToLeft)
        .preferredColorScheme(.dark)
        .task {
            await loadCourseContent()
        }
    }

    private func loadCourseContent() async {
        isLoading = true
        errorMessage = nil

        do {
            sections = try await coursesService.fetchCourseSections(courseId: course.id)

            if let userId = authManager.currentUser?.id {
                isEnrolled = try await coursesService.checkEnrollment(courseId: course.id, userId: userId)
                hasActiveSubscription = try await coursesService.checkActiveSubscription(userId: userId)
            }
        } catch {
            errorMessage = "تعذر تحميل محتوى الدورة. يرجى المحاولة مرة أخرى."
        }

        isLoading = false
    }
}

// Pill Badge Component
struct PillBadge: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
            Text(text)
                .font(.system(size: 13, weight: .semibold))
        }
        .foregroundColor(color)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(color.opacity(0.15))
        .cornerRadius(20)
    }
}

// Premium Section View
struct PremiumSectionView: View {
    let section: CourseSection
    let course: Course
    let isEnrolled: Bool
    let hasActiveSubscription: Bool
    @State private var isExpanded = true

    private func hasAccess(for lesson: CourseLesson) -> Bool {
        if course.isFree { return true }
        if lesson.isFreePreview { return true }
        if hasActiveSubscription && course.includedInSubscription { return true }
        if isEnrolled { return true }
        return false
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Section Header
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 14) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.accent)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(section.titleAr)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.primaryText)

                        if let description = section.descriptionAr, !description.isEmpty {
                            Text(description)
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.secondaryText)
                                .lineLimit(1)
                        }
                    }

                    Spacer()

                    if let lessons = section.lessons {
                        Text("\(lessons.count)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.primaryBackground)
                            .frame(width: 32, height: 32)
                            .background(Color.accent)
                            .clipShape(Circle())
                    }
                }
                .padding(18)
                .background(Color.cardBackground)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.tertiaryBackground, lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())

            // Lessons
            if isExpanded {
                if let lessons = section.lessons, !lessons.isEmpty {
                    VStack(spacing: 12) {
                        ForEach(lessons.sorted(by: { $0.orderIndex < $1.orderIndex })) { lesson in
                            PremiumLessonRow(
                                lesson: lesson,
                                isAccessible: hasAccess(for: lesson),
                                hasActiveSubscription: hasActiveSubscription
                            )
                        }
                    }
                    .padding(.leading, 8)
                } else {
                    Text("لا توجد دروس في هذا القسم")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.tertiaryText)
                        .padding(.leading, 26)
                        .padding(.vertical, 12)
                }
            }
        }
    }
}

// Premium Lesson Row
struct PremiumLessonRow: View {
    let lesson: CourseLesson
    let isAccessible: Bool
    let hasActiveSubscription: Bool

    var body: some View {
        NavigationLink(
            destination: isAccessible
                ? AnyView(PremiumVideoPlayerView(lesson: lesson))
                : AnyView(PremiumAccessDeniedView(hasActiveSubscription: hasActiveSubscription))
        ) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isAccessible ? Color.accentDim : Color.tertiaryBackground)
                        .frame(width: 50, height: 50)

                    Image(systemName: isAccessible ? "play.fill" : "lock.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(isAccessible ? .accent : .tertiaryText)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(lesson.titleAr)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 14) {
                        if lesson.isFreePreview {
                            HStack(spacing: 4) {
                                Image(systemName: "eye.fill")
                                    .font(.system(size: 10))
                                Text("معاينة")
                                    .font(.system(size: 11, weight: .medium))
                            }
                            .foregroundColor(.success)
                        }

                        if let duration = lesson.videoDuration {
                            HStack(spacing: 4) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 10))
                                Text("\(duration / 60) د")
                                    .font(.system(size: 11, weight: .medium))
                            }
                            .foregroundColor(.secondaryText)
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.left")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.tertiaryText)
            }
            .padding(16)
            .background(Color.cardBackground)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.tertiaryBackground, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Premium Access Denied View
struct PremiumAccessDeniedView: View {
    let hasActiveSubscription: Bool

    var body: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()

            VStack(spacing: 32) {
                ZStack {
                    Circle()
                        .fill(Color.premium.opacity(0.1))
                        .frame(width: 140, height: 140)
                        .blur(radius: 40)

                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 60, weight: .light))
                        .foregroundColor(.premium)
                }

                VStack(spacing: 16) {
                    Text("محتوى مقفل")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primaryText)

                    Text(hasActiveSubscription
                         ? "يجب التسجيل في الدورة للوصول إلى هذا المحتوى"
                         : "يجب تفعيل الاشتراك أو التسجيل في الدورة للوصول إلى هذا المحتوى")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .lineSpacing(4)
                }

                if !hasActiveSubscription {
                    Button(action: {
                        if let url = URL(string: "https://ecomclub.net/subscription") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack(spacing: 10) {
                            Text("عرض الخطط")
                                .font(.system(size: 17, weight: .semibold))
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.primaryBackground)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.premium)
                        .cornerRadius(16)
                        .shadow(color: Color.premium.opacity(0.3), radius: 20, x: 0, y: 8)
                    }
                    .padding(.horizontal, 32)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.layoutDirection, .rightToLeft)
        .preferredColorScheme(.dark)
    }
}

// Custom Corner Radius Extension (keep existing)
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
