import SwiftUI
import AVKit

struct ModernVideoPlayerView: View {
    let lesson: CourseLesson
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Video Player
                if let videoUrl = lesson.videoUrl, let url = URL(string: videoUrl) {
                    ZStack {
                        VideoPlayer(player: player)
                            .onAppear {
                                player = AVPlayer(url: url)
                                // Auto play
                                player?.play()
                                isPlaying = true
                            }
                            .onDisappear {
                                player?.pause()
                            }

                        // Custom Controls Overlay
                        VStack {
                            // Top Bar
                            HStack {
                                Button(action: {
                                    dismiss()
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .shadow(radius: 4)
                                }
                                Spacer()
                            }
                            .padding()

                            Spacer()
                        }
                    }
                    .frame(height: 280)
                } else {
                    Rectangle()
                        .fill(Color.black)
                        .frame(height: 280)
                        .overlay(
                            VStack(spacing: 16) {
                                Image(systemName: "video.slash.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white.opacity(0.6))
                                Text("الفيديو غير متاح")
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        )
                }

                // Content Section
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Title
                        Text(lesson.titleAr)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.primaryText)
                            .multilineTextAlignment(.leading)

                        // Duration Badge
                        if let duration = lesson.videoDuration {
                            HStack(spacing: 12) {
                                Label("\(duration / 60) دقيقة", systemImage: "clock.fill")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Color.accent)
                                    .cornerRadius(20)

                                if lesson.isFreePreview {
                                    Label("معاينة مجانية", systemImage: "eye.fill")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(Color.green)
                                        .cornerRadius(20)
                                }
                            }
                        }

                        Divider()

                        // Description
                        if let description = lesson.descriptionAr, !description.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "doc.text.fill")
                                        .foregroundColor(.accent)
                                    Text("عن الدرس")
                                        .font(.headline)
                                        .foregroundColor(.primaryText)
                                }

                                // HTML Text View for rich content
                                HTMLTextView(htmlString: description)
                                    .font(.body)
                                    .foregroundColor(.secondaryText)
                                    .padding(16)
                                    .background(Color.tertiaryBackground)
                                    .cornerRadius(12)
                            }
                        }

                        // Playback Controls Card
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "waveform")
                                    .foregroundColor(.accent)
                                Text("التحكم في التشغيل")
                                    .font(.headline)
                                    .foregroundColor(.primaryText)
                            }

                            HStack(spacing: 20) {
                                // Rewind 10s
                                ControlButton(icon: "gobackward.10") {
                                    if let player = player {
                                        let newTime = CMTimeAdd(player.currentTime(), CMTime(seconds: -10, preferredTimescale: 1))
                                        player.seek(to: newTime)
                                    }
                                }

                                // Play/Pause
                                ControlButton(icon: isPlaying ? "pause.circle.fill" : "play.circle.fill", size: 60) {
                                    if let player = player {
                                        if isPlaying {
                                            player.pause()
                                        } else {
                                            player.play()
                                        }
                                        isPlaying.toggle()
                                    }
                                }

                                // Forward 10s
                                ControlButton(icon: "goforward.10") {
                                    if let player = player {
                                        let newTime = CMTimeAdd(player.currentTime(), CMTime(seconds: 10, preferredTimescale: 1))
                                        player.seek(to: newTime)
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.cardBackground)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    }
                    .padding(20)
                }
                .background(Color.secondaryBackground)
            }
        }
        .navigationBarHidden(true)
        .environment(\.layoutDirection, .rightToLeft)
    }
}

// Control Button Component
struct ControlButton: View {
    let icon: String
    var size: CGFloat = 44
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size == 60 ? 40 : 24))
                .foregroundColor(.accent)
                .frame(width: size, height: size)
                .background(Color.accent.opacity(0.1))
                .clipShape(Circle())
        }
    }
}
