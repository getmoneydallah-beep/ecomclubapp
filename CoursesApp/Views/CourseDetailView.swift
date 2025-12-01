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
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Course Header
                if let thumbnailUrl = course.thumbnailUrl {
                    AsyncImage(url: URL(string: thumbnailUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                    }
                    .frame(height: 220)
                    .clipped()
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text(course.titleAr)
                        .font(.title)
                        .fontWeight(.bold)

                    if let description = course.descriptionAr {
                        Text(description)
                            .font(.body)
                            .foregroundColor(.gray)
                    }

                    HStack {
                        if course.isFree {
                            Text("مجاني")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(8)
                        } else if let price = course.price {
                            Text("\(String(format: "%.2f", price)) ريال")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }

                        Spacer()

                        if let difficulty = course.difficultyLevel {
                            Text(difficulty)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.2))
                                .cornerRadius(5)
                        }
                    }
                }
                .padding(.horizontal)

                Divider()
                    .padding(.horizontal)

                // Course Content
                if isLoading {
                    ProgressView("جاري تحميل المحتوى...")
                        .padding()
                } else if let error = errorMessage {
                    VStack {
                        Text("حدث خطأ في تحميل المحتوى")
                            .foregroundColor(.red)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                } else {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("محتوى الدورة")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)

                        ForEach(sections) { section in
                            SectionView(
                                section: section,
                                course: course,
                                isEnrolled: isEnrolled,
                                hasActiveSubscription: hasActiveSubscription
                            )
                        }
                    }
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .navigationBarTitleDisplayMode(.inline)
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

struct SectionView: View {
    let section: CourseSection
    let course: Course
    let isEnrolled: Bool
    let hasActiveSubscription: Bool
    @State private var isExpanded = true

    private func hasAccess(for lesson: CourseLesson) -> Bool {
        // Free course = everyone can access
        if course.isFree {
            return true
        }

        // Free preview lesson
        if lesson.isFreePreview {
            return true
        }

        // Active subscription + course included in subscription
        if hasActiveSubscription && course.includedInSubscription {
            return true
        }

        // User purchased course individually
        if isEnrolled {
            return true
        }

        return false
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(section.titleAr)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }

            if isExpanded {
                if let lessons = section.lessons, !lessons.isEmpty {
                    ForEach(lessons.sorted(by: { $0.orderIndex < $1.orderIndex })) { lesson in
                        LessonRowView(lesson: lesson, isAccessible: hasAccess(for: lesson))
                    }
                } else {
                    Text("لا توجد دروس في هذا القسم")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding()
                }
            }
        }
        .padding(.horizontal)
    }
}

struct LessonRowView: View {
    let lesson: CourseLesson
    let isAccessible: Bool

    var body: some View {
        NavigationLink(
            destination: isAccessible ? AnyView(VideoPlayerView(lesson: lesson)) : AnyView(AccessDeniedView())
        ) {
            HStack(spacing: 12) {
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundColor(isAccessible ? .blue : .gray)

                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.titleAr)
                        .font(.subheadline)
                        .foregroundColor(.primary)

                    HStack {
                        if lesson.isFreePreview {
                            Text("معاينة مجانية")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }

                        if let duration = lesson.videoDuration {
                            Text("\(duration / 60) دقيقة")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                }

                Spacer()

                if !isAccessible {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
        }
    }
}

struct AccessDeniedView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("يجب التسجيل في الدورة للوصول إلى هذا الدرس")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}
