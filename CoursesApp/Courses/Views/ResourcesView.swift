import SwiftUI

struct ResourcesView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var subscriptionManager = SubscriptionManager()
    @State private var resources: [Resource] = []
    @State private var selectedCategory: ResourceCategory? = nil
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showingSettings = false

    private let resourcesService = ResourcesService()

    var filteredResources: [Resource] {
        if let category = selectedCategory {
            return resources.filter { $0.category == category }
        }
        return resources
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.primaryBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    categoryFiltersView
                    resourcesContentView
                }
            }
            .navigationTitle("المصادر")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    settingsButton
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(authManager)
            }
            .task {
                await loadResources()
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }

    private var categoryFiltersView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                CategoryFilterButton(
                    title: "الكل",
                    isSelected: selectedCategory == nil,
                    action: { selectedCategory = nil }
                )

                ForEach(ResourceCategory.allCases, id: \.self) { category in
                    CategoryFilterButton(
                        title: category.displayName,
                        isSelected: selectedCategory == category,
                        action: { selectedCategory = category }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 16)
        }
        .background(Color.secondaryBackground)
    }

    @ViewBuilder
    private var resourcesContentView: some View {
        if isLoading {
            Spacer()
            ProgressView()
                .tint(Color.accent)
            Spacer()
        } else if let error = errorMessage {
            Spacer()
            PremiumErrorView(message: error) {
                Task { await loadResources() }
            }
            Spacer()
        } else if filteredResources.isEmpty {
            Spacer()
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color.accentDim)
                        .frame(width: 100, height: 100)
                        .blur(radius: 30)

                    Image(systemName: "folder")
                        .font(.system(size: 50, weight: .ultraLight))
                        .foregroundColor(.tertiaryText)
                }

                Text("لا توجد موارد في هذه الفئة")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondaryText)
            }
            Spacer()
        } else {
            resourcesListView
        }
    }

    private var resourcesListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredResources) { resource in
                    ResourceCard(
                        resource: resource,
                        hasSubscription: subscriptionManager.hasActiveSubscription,
                        onTap: {
                            openResource(resource)
                        }
                    )
                }
            }
            .padding()
        }
    }

    private var settingsButton: some View {
        Button {
            showingSettings = true
        } label: {
            Image(systemName: "gearshape.fill")
                .foregroundColor(Color.accent)
        }
    }

    private func loadResources() async {
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
            resources = try await resourcesService.fetchResources()
            isLoading = false
        } catch {
            errorMessage = "فشل في تحميل المصادر: \(error.localizedDescription)"
            isLoading = false
        }
    }

    private func openResource(_ resource: Resource) {
        // Check access
        if !subscriptionManager.hasAccess(for: resource) {
            // Show premium prompt
            errorMessage = "هذا المورد متاح للمشتركين فقط"
            return
        }

        // Open file URL
        if let url = URL(string: resource.fileUrl) {
            UIApplication.shared.open(url)
        }
    }
}

struct CategoryFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? Color.primaryBackground : Color.primaryText)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? Color.accent : Color.cardBackground)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color.tertiaryText.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

struct ResourceCard: View {
    let resource: Resource
    let hasSubscription: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // File type icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colorForCategory(resource.category).opacity(0.15))
                        .frame(width: 60, height: 60)

                    Image(systemName: iconForFileType(resource.fileType))
                        .font(.system(size: 24))
                        .foregroundColor(colorForCategory(resource.category))
                }

                // Content
                VStack(alignment: .leading, spacing: 6) {
                    Text(resource.titleAr)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.primaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Text(resource.descriptionAr)
                        .font(.system(size: 13))
                        .foregroundColor(Color.secondaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 8) {
                        // Category badge
                        Text(resource.category.displayName)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(colorForCategory(resource.category))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(colorForCategory(resource.category).opacity(0.1))
                            .cornerRadius(6)

                        // Free/Premium badge
                        if resource.isFree {
                            Text("مجاني")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(Color.success)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.success.opacity(0.1))
                                .cornerRadius(6)
                        } else {
                            HStack(spacing: 4) {
                                Image(systemName: hasSubscription ? "checkmark.circle.fill" : "lock.fill")
                                    .font(.system(size: 10))
                                Text(hasSubscription ? "متاح" : "مشترك")
                            }
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(hasSubscription ? Color.success : Color.premium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background((hasSubscription ? Color.success : Color.premium).opacity(0.1))
                            .cornerRadius(6)
                        }
                    }
                }

                Spacer()

                // Download icon
                Image(systemName: "arrow.down.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color.accent)
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(colorForCategory(resource.category).opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func iconForFileType(_ fileType: String) -> String {
        switch fileType.lowercased() {
        case "pdf": return "doc.fill"
        case "xlsx", "xls": return "tablecells.fill"
        case "docx", "doc": return "doc.text.fill"
        case "zip": return "archivebox.fill"
        default: return "doc.fill"
        }
    }

    private func colorForCategory(_ category: ResourceCategory) -> Color {
        switch category {
        case .templates: return Color(hex: "FF6B6B")
        case .tools: return Color.accent
        case .guides: return Color.premium
        case .checklists: return Color.success
        case .aiPrompts: return Color(hex: "9B59B6")
        }
    }
}
