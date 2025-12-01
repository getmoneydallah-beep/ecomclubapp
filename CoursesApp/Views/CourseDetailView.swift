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
            Color.secondaryBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Hero Image
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
                                                colors: [.accent, .premium],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(height: 280)
                            .clipped()
                        }

                        // Gradient Overlay
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 280)

                        // Badge
                        HStack {
                            if course.isFree {
                                Label("مجاني", systemImage: "checkmark.seal.fill")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(.green)
                                    .cornerRadius(20)
                            } else if let price = course.price, price > 0 {
                                Label("\(String(format: "%.0f", price)) ريال", systemImage: "creditcard.fill")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(.blue)
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
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primaryText)
                            .multilineTextAlignment(.leading)

                        // Description
                        if let description = course.descriptionAr {
                            Text(description)
                                .font(.body)
                                .foregroundColor(.secondaryText)
                                .multilineTextAlignment(.leading)
                        }

                        // Metadata
                        HStack(spacing: 20) {
                            if let difficulty = course.difficultyLevel {
                                MetadataItem(icon: "chart.bar.fill", text: difficulty, color: .orange)
                            }

                            if let duration = course.durationHours {
                                MetadataItem(icon: "clock.fill", text: "\(String(format: "%.0f", duration)) ساعة", color: .blue)
                            }
                        }

                        Divider()
                            .padding(.vertical, 8)

                        // Course Content Header
                        HStack {
                            Text("محتوى الدورة")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primaryText)
                            Spacer()
                        }

                        // Loading / Error / Content
                        if isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                            .padding(.vertical, 40)
                        } else if let error = errorMessage {
                            VStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.red)
                                Text(error)
                                    .font(.subheadline)
                                    .foregroundColor(.secondaryText)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                        } else {
                            VStack(spacing: 16) {
                                ForEach(sections) { section in
                                    ModernSectionView(
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
                    .background(Color.cardBackground)
                    .cornerRadius(32, corners: [.topLeft, .topRight])
                    .offset(y: -30)
                }
            }
            .ignoresSafeArea(edges: .top)
        }
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.layoutDirection, .rightToLeft)
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

// Metadata Item Component
struct MetadataItem: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondaryText)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

// Modern Section View
struct ModernSectionView: View {
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
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: isExpanded ? "chevron.down.circle.fill" : "chevron.left.circle.fill")
                        .font(.title3)
                        .foregroundColor(.accent)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(section.titleAr)
                            .font(.headline)
                            .foregroundColor(.primaryText)

                        if let description = section.descriptionAr, !description.isEmpty {
                            Text(description)
                                .font(.caption)
                                .foregroundColor(.secondaryText)
                                .lineLimit(1)
                        }
                    }

                    Spacer()

                    if let lessons = section.lessons {
                        Text("\(lessons.count)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.accent)
                            .clipShape(Circle())
                    }
                }
                .padding(16)
                .background(Color.tertiaryBackground)
                .cornerRadius(16)
            }
            .buttonStyle(PlainButtonStyle())

            // Lessons
            if isExpanded {
                if let lessons = section.lessons, !lessons.isEmpty {
                    VStack(spacing: 10) {
                        ForEach(lessons.sorted(by: { $0.orderIndex < $1.orderIndex })) { lesson in
                            ModernLessonRow(lesson: lesson, isAccessible: hasAccess(for: lesson))
                        }
                    }
                    .padding(.leading, 12)
                } else {
                    Text("لا توجد دروس في هذا القسم")
                        .font(.caption)
                        .foregroundColor(.tertiaryText)
                        .padding()
                }
            }
        }
    }
}

// Modern Lesson Row
struct ModernLessonRow: View {
    let lesson: CourseLesson
    let isAccessible: Bool

    var body: some View {
        NavigationLink(
            destination: isAccessible ? AnyView(ModernVideoPlayerView(lesson: lesson)) : AnyView(ModernAccessDeniedView())
        ) {
            HStack(spacing: 14) {
                // Play Icon
                ZStack {
                    Circle()
                        .fill(isAccessible ? Color.accent.opacity(0.15) : Color.gray.opacity(0.1))
                        .frame(width: 48, height: 48)

                    Image(systemName: isAccessible ? "play.circle.fill" : "lock.circle.fill")
                        .font(.title2)
                        .foregroundColor(isAccessible ? .accent : .gray)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(lesson.titleAr)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primaryText)
                        .lineLimit(2)

                    HStack(spacing: 12) {
                        if lesson.isFreePreview {
                            Label("معاينة مجانية", systemImage: "eye.fill")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }

                        if let duration = lesson.videoDuration {
                            Label("\(duration / 60) دقيقة", systemImage: "clock.fill")
                                .font(.caption2)
                                .foregroundColor(.secondaryText)
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.left")
                    .font(.caption)
                    .foregroundColor(.tertiaryText)
            }
            .padding(14)
            .background(Color.cardBackground)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Modern Access Denied
struct ModernAccessDeniedView: View {
    var body: some View {
        ZStack {
            Color.secondaryBackground
                .ignoresSafeArea()

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.1))
                        .frame(width: 120, height: 120)

                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                }

                VStack(spacing: 12) {
                    Text("محتوى مقفل")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryText)

                    Text("يجب التسجيل في الدورة أو تفعيل الاشتراك للوصول إلى هذا الدرس")
                        .font(.body)
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                Button(action: {}) {
                    Text("عرض خطط الاشتراك")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(Color.accent)
                        .cornerRadius(14)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.layoutDirection, .rightToLeft)
    }
}

// Custom Corner Radius Extension
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
