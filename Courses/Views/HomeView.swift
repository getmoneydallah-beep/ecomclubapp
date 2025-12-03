import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var subscriptionManager = SubscriptionManager()
    @State private var announcements: [Announcement] = []
    @State private var userStats: UserStats?
    @State private var challenges: [Challenge] = []
    @State private var userChallenges: [UserChallenge] = []
    @State private var liveEvents: [LiveEvent] = []
    @State private var communityWins: [CommunityWin] = []
    @State private var courses: [Course] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showingSettings = false
    @State private var showingCreateWin = false

    private let announcementsService = AnnouncementsService()
    private let statsService = UserStatsService()
    private let challengesService = ChallengesService()
    private let eventsService = LiveEventsService()
    private let communityService = CommunityService()
    private let coursesService = CoursesService()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.primaryBackground.ignoresSafeArea()

                if isLoading {
                    ProgressView()
                        .tint(Color.accent)
                } else if let error = errorMessage {
                    PremiumErrorView(message: error) {
                        Task { await loadData() }
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Announcements Banner
                            if !announcements.isEmpty {
                                AnnouncementsBanner(announcements: announcements)
                            }

                            // User Stats Card
                            if let stats = userStats {
                                UserStatsCard(stats: stats)
                            }

                            // Challenges Section
                            if !challenges.isEmpty {
                                ChallengesSection(
                                    challenges: challenges,
                                    userChallenges: userChallenges,
                                    onStartChallenge: { challenge in
                                        await startChallenge(challenge)
                                    }
                                )
                            }

                            // Live Events Section
                            if !liveEvents.isEmpty {
                                LiveEventsSection(
                                    events: liveEvents,
                                    hasSubscription: subscriptionManager.hasActiveSubscription
                                )
                            }

                            // Community Wins Section
                            CommunityWinsSection(
                                wins: communityWins,
                                hasSubscription: subscriptionManager.hasActiveSubscription,
                                onCreateWin: {
                                    showingCreateWin = true
                                },
                                onRefresh: {
                                    await loadCommunityWins()
                                }
                            )

                            // Courses by Track Section
                            CoursesSection(courses: courses)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("الرئيسية")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(Color.accent)
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(authManager)
            }
            .sheet(isPresented: $showingCreateWin) {
                CreateCommunityWinView { success in
                    if success {
                        Task { await loadCommunityWins() }
                    }
                }
                .environmentObject(authManager)
            }
            .task {
                await loadData()
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }

    private func loadData() async {
        isLoading = true
        errorMessage = nil

        guard let userId = authManager.currentUser?.id else {
            errorMessage = "لم يتم العثور على معلومات المستخدم"
            isLoading = false
            return
        }

        // Check subscription status
        await subscriptionManager.checkSubscriptionStatus(userId: userId)

        do {
            async let announcementsTask = announcementsService.fetchActiveAnnouncements()
            async let statsTask = statsService.fetchUserStats(userId: userId)
            async let challengesTask = challengesService.fetchActiveChallenges()
            async let userChallengesTask = challengesService.fetchUserChallenges(userId: userId)
            async let eventsTask = eventsService.fetchUpcomingEvents()
            async let winsTask = communityService.fetchApprovedWins(limit: 10)
            async let coursesTask = coursesService.fetchCourses()

            announcements = try await announcementsTask
            userStats = try await statsTask
            challenges = try await challengesTask
            userChallenges = try await userChallengesTask
            liveEvents = try await eventsTask
            communityWins = try await winsTask
            courses = try await coursesTask

            isLoading = false
        } catch {
            errorMessage = "فشل في تحميل البيانات: \(error.localizedDescription)"
            isLoading = false
        }
    }

    private func startChallenge(_ challenge: Challenge) async {
        guard let userId = authManager.currentUser?.id else { return }

        do {
            try await challengesService.startChallenge(userId: userId, challengeId: challenge.id)
            await loadData() // Reload to update user challenges
        } catch {
            errorMessage = "فشل في بدء التحدي: \(error.localizedDescription)"
        }
    }

    private func loadCommunityWins() async {
        do {
            communityWins = try await communityService.fetchApprovedWins(limit: 10)
        } catch {
            errorMessage = "فشل في تحميل الإنجازات: \(error.localizedDescription)"
        }
    }
}
