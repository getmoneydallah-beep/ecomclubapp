import SwiftUI

struct CoursesListView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var courses: [Course] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let coursesService = CoursesService()

    var body: some View {
        NavigationView {
            ZStack {
                // Deep black background
                Color.primaryBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    if isLoading {
                        VStack(spacing: 24) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .accent))
                                .scaleEffect(1.3)
                            Text("جاري التحميل...")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondaryText)
                        }
                        .frame(maxHeight: .infinity)
                    } else if let error = errorMessage {
                        PremiumErrorView(message: error) {
                            Task {
                                await loadCourses()
                            }
                        }
                    } else if courses.isEmpty {
                        PremiumEmptyStateView()
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 20) {
                                ForEach(courses) { course in
                                    NavigationLink(destination: CourseDetailView(course: course)) {
                                        PremiumCourseCard(course: course)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                    }
                }
                .navigationTitle("الدورات")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            Task {
                                await authManager.signOut()
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 15, weight: .medium))
                                Text("خروج")
                                    .font(.system(size: 15, weight: .medium))
                            }
                            .foregroundColor(.accent)
                        }
                    }
                }
            }
            .environment(\.layoutDirection, .rightToLeft)
            .task {
                await loadCourses()
            }
        }
        .preferredColorScheme(.dark)
    }

    private func loadCourses() async {
        isLoading = true
        errorMessage = nil

        do {
            courses = try await coursesService.fetchCourses()
        } catch {
            errorMessage = "تعذر تحميل الدورات. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى."
        }

        isLoading = false
    }
}

// Premium Course Card
struct PremiumCourseCard: View {
    let course: Course

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Thumbnail with gradient overlay
            ZStack(alignment: .topTrailing) {
                if let thumbnailUrl = course.thumbnailUrl {
                    AsyncImage(url: URL(string: thumbnailUrl)) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.tertiaryBackground)
                                .overlay(
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .accent))
                                )
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .overlay(
                                    LinearGradient(
                                        colors: [.clear, Color.primaryBackground.opacity(0.3)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        case .failure:
                            Rectangle()
                                .fill(Color.tertiaryBackground)
                                .overlay(
                                    Image(systemName: "photo.fill")
                                        .font(.system(size: 30, weight: .light))
                                        .foregroundColor(.tertiaryText)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(height: 200)
                    .clipped()
                } else {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.accentDim, Color.tertiaryBackground],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 200)
                        .overlay(
                            Image(systemName: "play.rectangle.fill")
                                .font(.system(size: 50, weight: .ultraLight))
                                .foregroundColor(.accent)
                        )
                }

                // Badge
                if course.isFree {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 11))
                        Text("مجاني")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(.primaryBackground)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.success)
                    .cornerRadius(20)
                    .padding(14)
                }
            }

            // Content
            VStack(alignment: .leading, spacing: 14) {
                Text(course.titleAr)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                if let description = course.descriptionAr {
                    Text(description)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                // Metadata
                HStack(spacing: 16) {
                    if let difficulty = course.difficultyLevel {
                        HStack(spacing: 6) {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 11))
                            Text(difficulty)
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(.secondaryText)
                    }

                    if let duration = course.durationHours {
                        HStack(spacing: 6) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 11))
                            Text("\(String(format: "%.0f", duration)) ساعة")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(.secondaryText)
                    }

                    Spacer()

                    if !course.isFree {
                        if let price = course.price, price > 0 {
                            Text("\(String(format: "%.0f", price)) ريال")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.accent)
                        }
                    }
                }
            }
            .padding(18)
        }
        .background(Color.cardBackground)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.accentDim, Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.accentGlow.opacity(0.1), radius: 16, x: 0, y: 8)
    }
}

// Premium Empty State
struct PremiumEmptyStateView: View {
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.accentDim)
                    .frame(width: 100, height: 100)
                    .blur(radius: 30)

                Image(systemName: "tray.fill")
                    .font(.system(size: 50, weight: .ultraLight))
                    .foregroundColor(.tertiaryText)
            }

            VStack(spacing: 8) {
                Text("لا توجد دورات")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primaryText)

                Text("لا توجد دورات متاحة حالياً")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.secondaryText)
            }
        }
        .frame(maxHeight: .infinity)
    }
}

// Premium Error View
struct PremiumErrorView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            ZStack {
                Circle()
                    .fill(Color.danger.opacity(0.1))
                    .frame(width: 100, height: 100)
                    .blur(radius: 20)

                Image(systemName: "wifi.exclamationmark")
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(.danger)
            }

            VStack(spacing: 12) {
                Text("حدث خطأ")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primaryText)

                Text(message)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button(action: retryAction) {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 15, weight: .semibold))
                    Text("إعادة المحاولة")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.primaryBackground)
                .frame(width: 200, height: 50)
                .background(Color.accent)
                .cornerRadius(14)
                .shadow(color: Color.accentGlow, radius: 16, x: 0, y: 6)
            }
        }
        .frame(maxHeight: .infinity)
    }
}
