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
                // Background
                Color.secondaryBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    if isLoading {
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("جاري التحميل...")
                                .foregroundColor(.secondaryText)
                        }
                        .frame(maxHeight: .infinity)
                    } else if let error = errorMessage {
                        ErrorView(message: error) {
                            Task {
                                await loadCourses()
                            }
                        }
                    } else if courses.isEmpty {
                        EmptyStateView()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 20) {
                                ForEach(courses) { course in
                                    NavigationLink(destination: CourseDetailView(course: course)) {
                                        ModernCourseCard(course: course)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding()
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
                            HStack(spacing: 6) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("خروج")
                            }
                            .font(.subheadline)
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

// Modern Course Card
struct ModernCourseCard: View {
    let course: Course
    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Thumbnail
            ZStack(alignment: .topTrailing) {
                if let thumbnailUrl = course.thumbnailUrl {
                    AsyncImage(url: URL(string: thumbnailUrl)) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.tertiaryBackground)
                                .overlay(
                                    ProgressView()
                                )
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            Rectangle()
                                .fill(Color.tertiaryBackground)
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundColor(.secondaryText)
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
                                colors: [.accent.opacity(0.6), .premium.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 200)
                        .overlay(
                            Image(systemName: "play.rectangle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white.opacity(0.8))
                        )
                }

                // Free/Price Badge
                if course.isFree {
                    Text("مجاني")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.green)
                        .cornerRadius(20)
                        .padding(12)
                }
            }

            // Content
            VStack(alignment: .leading, spacing: 12) {
                Text(course.titleAr)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                if let description = course.descriptionAr {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                // Metadata Row
                HStack(spacing: 16) {
                    if let difficulty = course.difficultyLevel {
                        Label(difficulty, systemImage: "chart.bar.fill")
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                    }

                    if let duration = course.durationHours {
                        Label("\(String(format: "%.0f", duration)) ساعة", systemImage: "clock.fill")
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                    }

                    Spacer()

                    if !course.isFree {
                        if let price = course.price, price > 0 {
                            Text("\(String(format: "%.0f", price)) ريال")
                                .font(.headline)
                                .foregroundColor(.accent)
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(Color.cardBackground)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onTapGesture {
            isPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }
    }
}

// Empty State View
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.tertiaryText)

            Text("لا توجد دورات متاحة حالياً")
                .font(.headline)
                .foregroundColor(.secondaryText)
        }
        .frame(maxHeight: .infinity)
    }
}

// Error View
struct ErrorView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.red)

            Text("حدث خطأ")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primaryText)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: retryAction) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("إعادة المحاولة")
                }
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.accent)
                .cornerRadius(12)
            }
        }
        .frame(maxHeight: .infinity)
    }
}
