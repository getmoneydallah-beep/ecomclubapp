import SwiftUI

struct CoursesListView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var courses: [Course] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let coursesService = CoursesService()

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("جاري التحميل...")
                } else if let error = errorMessage {
                    VStack(spacing: 10) {
                        Text("حدث خطأ")
                            .font(.headline)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.gray)
                        Button("إعادة المحاولة") {
                            Task {
                                await loadCourses()
                            }
                        }
                    }
                } else if courses.isEmpty {
                    Text("لا توجد دورات متاحة")
                        .foregroundColor(.gray)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(courses) { course in
                                NavigationLink(destination: CourseDetailView(course: course)) {
                                    CourseCardView(course: course)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("الدورات")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("تسجيل الخروج") {
                        Task {
                            await authManager.signOut()
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

struct CourseCardView: View {
    let course: Course

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let thumbnailUrl = course.thumbnailUrl {
                AsyncImage(url: URL(string: thumbnailUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(height: 180)
                .clipped()
                .cornerRadius(10)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(course.titleAr)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)

                if let description = course.descriptionAr {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }

                HStack {
                    if course.isFree {
                        Text("مجاني")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(5)
                    } else if let price = course.price {
                        Text("\(String(format: "%.2f", price)) ريال")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }

                    Spacer()

                    if let duration = course.durationHours {
                        HStack(spacing: 3) {
                            Image(systemName: "clock")
                            Text("\(String(format: "%.1f", duration)) ساعة")
                        }
                        .font(.caption)
                        .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 5)
            .padding(.bottom, 5)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
