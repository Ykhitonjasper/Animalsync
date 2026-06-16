import SwiftUI
import SwiftData

struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("hasSeededMockData") private var hasSeededMockData = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("reminderLeadDays") private var reminderLeadDays = 3
    @Environment(\.modelContext) private var context
    @Query private var pets: [Pet]

    var body: some View {
        ZStack {
            MainTabView()
        }
        .preferredColorScheme(.dark)
        .task {
            await StoreKitManager.shared.loadProducts()
            await StoreKitManager.shared.refreshEntitlements()
            #if DEBUG
            if !hasSeededMockData && pets.isEmpty {
                MockSeeder.seed(into: context)
                hasSeededMockData = true
            }
            #endif
            await NotificationCoordinator.syncFromContext(
                context,
                enabled: notificationsEnabled,
                leadDays: reminderLeadDays
            )
        }
        .fullScreenCover(isPresented: .constant(!hasCompletedOnboarding)) {
            OnboardingScreen {
                hasCompletedOnboarding = true
            }
        }
        .onAppear {
            DispatchQueue.main.async {
                AnalyticsBootstrap.startAfterFirstFrameIfNeeded()
            }
        }
    }
}

#Preview {
    RootView()
        .modelContainer(for: [Pet.self, Trip.self, PetDocument.self], inMemory: true)
}
