import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let lesson: CourseLesson
    @State private var player: AVPlayer?

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            if let videoUrl = lesson.videoUrl, let url = URL(string: videoUrl) {
                VideoPlayer(player: player)
                    .frame(height: 250)
                    .onAppear {
                        player = AVPlayer(url: url)
                    }
                    .onDisappear {
                        player?.pause()
                    }
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 250)
                    .overlay(
                        VStack {
                            Image(systemName: "video.slash")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("الفيديو غير متاح")
                                .foregroundColor(.gray)
                        }
                    )
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Text(lesson.titleAr)
                        .font(.title2)
                        .fontWeight(.bold)

                    if let description = lesson.descriptionAr {
                        Text(description)
                            .font(.body)
                            .foregroundColor(.gray)
                    }

                    if let duration = lesson.videoDuration {
                        HStack {
                            Image(systemName: "clock")
                            Text("المدة: \(duration / 60) دقيقة")
                        }
                        .font(.caption)
                        .foregroundColor(.gray)
                    }

                    Divider()

                    // Controls
                    HStack(spacing: 20) {
                        Button(action: {
                            if player?.timeControlStatus == .playing {
                                player?.pause()
                            } else {
                                player?.play()
                            }
                        }) {
                            Image(systemName: player?.timeControlStatus == .playing ? "pause.circle.fill" : "play.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.blue)
                        }

                        Spacer()
                    }
                }
                .padding()
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .navigationBarTitleDisplayMode(.inline)
    }
}
