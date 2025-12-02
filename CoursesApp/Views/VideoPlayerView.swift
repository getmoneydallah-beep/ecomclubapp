import SwiftUI
import AVKit

struct PremiumVideoPlayerView: View {
    let lesson: CourseLesson
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Video Player Section
                if let videoUrl = lesson.videoUrl, let url = URL(string: videoUrl) {
                    ZStack {
                        VideoPlayer(player: player)
                            .onAppear {
                                player = AVPlayer(url: url)
                                player?.play()
                                isPlaying = true
                            }
                            .onDisappear {
                                player?.pause()
                            }

                        // Custom overlay for close button
                        VStack {
                            HStack {
                                Spacer()
                                Button(action: {
                                    dismiss()
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.primaryBackground.opacity(0.8))
                                            .frame(width: 44, height: 44)
                                            .blur(radius: 2)

                                        Image(systemName: "xmark")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.primaryText)
                                    }
                                }
                                .padding(16)
                            }
                            Spacer()
                        }
                    }
                    .frame(height: 280)
                } else {
                    Rectangle()
                        .fill(Color.tertiaryBackground)
                        .frame(height: 280)
                        .overlay(
                            VStack(spacing: 20) {
                                Image(systemName: "video.slash.fill")
                                    .font(.system(size: 50, weight: .ultraLight))
                                    .foregroundColor(.tertiaryText)
                                Text("الفيديو غير متاح")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.secondaryText)
                            }
                        )
                }

                // Content Section
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        // Title
                        Text(lesson.titleAr)
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.primaryText)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(2)

                        // Metadata badges
                        HStack(spacing: 12) {
                            if let duration = lesson.videoDuration {
                                HStack(spacing: 8) {
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 12))
                                    Text("\(duration / 60) دقيقة")
                                        .font(.system(size: 13, weight: .semibold))
                                }
                                .foregroundColor(.accent)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color.accentDim)
                                .cornerRadius(20)
                            }

                            if lesson.isFreePreview {
                                HStack(spacing: 8) {
                                    Image(systemName: "eye.fill")
                                        .font(.system(size: 12))
                                    Text("معاينة مجانية")
                                        .font(.system(size: 13, weight: .semibold))
                                }
                                .foregroundColor(.success)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color.success.opacity(0.15))
                                .cornerRadius(20)
                            }
                        }

                        // Divider
                        Rectangle()
                            .fill(Color.tertiaryBackground)
                            .frame(height: 1)

                        // Description Section
                        if let description = lesson.descriptionAr, !description.isEmpty {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack(spacing: 10) {
                                    Image(systemName: "text.alignright")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.accent)
                                    Text("الوصف")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.primaryText)
                                }

                                HTMLTextView(htmlString: description)
                                    .padding(18)
                                    .background(Color.cardBackground)
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .strokeBorder(Color.tertiaryBackground, lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .frame(maxWidth: 800)
                    .frame(maxWidth: .infinity)
                    .padding(24)
                }
                .background(Color.primaryBackground)
            }
        }
        .navigationBarHidden(true)
        .environment(\.layoutDirection, .rightToLeft)
        .preferredColorScheme(.dark)
    }
}
