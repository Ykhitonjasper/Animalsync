import SwiftUI
import SwiftData

struct TripListScreen: View {
    @Query(sort: \Trip.entryDate, order: .reverse) private var trips: [Trip]
    @Query private var pets: [Pet]
    private var store = StoreKitManager.shared
    private var gate = FreemiumGate.shared
    @State private var showCreate = false
    @State private var showPaywall = false

    private var activeTrips: [Trip] { trips.filter { $0.status != .past } }
    private var pastTrips: [Trip] { trips.filter { $0.status == .past } }

    private func pet(for trip: Trip) -> Pet? {
        pets.first { $0.id == trip.petID }
    }

    var body: some View {
        Group {
            if trips.isEmpty {
                EmptyStateView(
                    icon: "airplane.departure",
                    title: "No trips yet",
                    message: "Set a destination and entry date. Animalsync builds a reverse timeline of every vaccination, test, and document you need.",
                    actionTitle: "Plan Trip"
                ) { showCreate = true }
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                        AppNavigationTitle(
                            title: "Trips",
                            subtitle: "Active itineraries and preparation timelines",
                            badge: "\(activeTrips.count) active",
                            action: {
                                if gate.isTripCreationAllowed(currentActiveCount: activeTrips.count, isPro: store.isPro) {
                                    showCreate = true
                                } else {
                                    showPaywall = true
                                }
                            },
                            actionLabel: "Plan Trip"
                        )

                        if !activeTrips.isEmpty {
                            SectionHeader(title: "Active", subtitle: "\(activeTrips.count) planned")
                            ForEach(activeTrips) { trip in
                                NavigationLink(value: trip) {
                                    TripCard(trip: trip, pet: pet(for: trip))
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        if !activeTrips.isEmpty && !gate.isTripCreationAllowed(currentActiveCount: activeTrips.count, isPro: store.isPro) {
                            ProGateBanner(
                                title: "Plan more trips with Pro",
                                message: "Free plan covers 1 active trip."
                            ) { showPaywall = true }
                        }

                        if !pastTrips.isEmpty {
                            SectionHeader(title: "Past", subtitle: "\(pastTrips.count) completed")
                            ForEach(pastTrips) { trip in
                                NavigationLink(value: trip) {
                                    TripCard(trip: trip, pet: pet(for: trip), dimmed: true)
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        LegalFootnote()
                    }
                    .padding(.horizontal, AppTheme.spacingMD)
                    .padding(.bottom, AppTheme.spacingLG)
                }
            }
        }
        .appScreen()
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationDestination(for: Trip.self) { trip in
            TimelineScreen(trip: trip)
        }
        .sheet(isPresented: $showCreate) { TripCreateScreen() }
        .sheet(isPresented: $showPaywall) { PaywallScreen() }
    }
}
