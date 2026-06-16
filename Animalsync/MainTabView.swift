import SwiftUI

struct MainTabView: View {
    @AppStorage("selectedTab") private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                PetListScreen()
            }
            .tabItem {
                Label("Pets", systemImage: "pawprint.fill")
            }
            .tag(0)

            NavigationStack {
                TripListScreen()
            }
            .tabItem {
                Label("Trips", systemImage: "airplane.departure")
            }
            .tag(1)

            NavigationStack {
                DocumentsScreen()
            }
            .tabItem {
                Label("Documents", systemImage: "doc.text.fill")
            }
            .tag(2)

            NavigationStack {
                EmergencyHubScreen()
            }
            .tabItem {
                Label("Help", systemImage: "lifepreserver.fill")
            }
            .tag(3)
        }
        .tint(.appGold)
        .preferredColorScheme(.dark)
        .onAppear {
            TabBarGlassStyle.apply()
            NavigationBarFestiveStyle.apply()
        }
        .onChange(of: selectedTab) { _, _ in
            Haptic.selection()
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Pet.self, Trip.self, PetDocument.self], inMemory: true)
}
