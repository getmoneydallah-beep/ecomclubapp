import SwiftUI

struct CoursesSection: View {
    let courses: [Course]
    @State private var selectedTrack: CourseTrack = .beginnerRoadmap

    var filteredCourses: [Course] {
        courses.filter { course in
            // Assuming courses have a track field - if not, we'll show all
            true // You can add track filtering here if needed
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "book.fill")
                    .foregroundColor(Color.accent)
                Text("الدورات التدريبية")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.primaryText)
                Spacer()
            }

            // Track filters - commented out for now as course model may not have track field
            // ScrollView(.horizontal, showsIndicators: false) {
            //     HStack(spacing: 8) {
            //         ForEach(CourseTrack.allCases, id: \.self) { track in
            //             TrackFilterButton(
            //                 title: track.displayName,
            //                 isSelected: selectedTrack == track,
            //                 action: { selectedTrack = track }
            //             )
            //         }
            //     }
            // }

            // Courses grid
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(filteredCourses.prefix(6)) { course in
                    NavigationLink(destination: CourseDetailView(course: course)) {
                        PremiumCourseCard(course: course)
                    }
                }
            }
        }
    }
}

struct TrackFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isSelected ? Color.primaryBackground : Color.secondaryText)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accent : Color.cardBackground)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color.tertiaryText, lineWidth: 1)
                )
        }
    }
}
