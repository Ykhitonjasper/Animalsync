import SwiftUI
import SwiftData

struct PetListScreen: View {
    @Query(sort: \Pet.createdAt) private var pets: [Pet]
    @Query private var trips: [Trip]
    private var store = StoreKitManager.shared
    private var gate = FreemiumGate.shared
    @State private var showCreate = false
    @State private var showPaywall = false

    private var nextTripPerPet: [UUID: Trip] {
        var map: [UUID: Trip] = [:]
        for trip in trips where trip.status != .past {
            if let existing = map[trip.petID], existing.entryDate < trip.entryDate {
                continue
            }
            map[trip.petID] = trip
        }
        return map
    }

    var body: some View {
        Group {
            if pets.isEmpty {
                EmptyStateView(
                    icon: "pawprint.circle.fill",
                    title: "No pets yet",
                    message: "Add your first pet to start building a travel-ready profile with vaccines, documents, and trip timelines.",
                    actionTitle: "Add Pet"
                ) { showCreate = true }
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                        AppNavigationTitle(
                            title: "Pets",
                            subtitle: "Profiles, vaccines, and upcoming travel",
                            badge: "\(pets.count)",
                            action: {
                                if gate.isPetCreationAllowed(currentCount: pets.count, isPro: store.isPro) {
                                    showCreate = true
                                } else {
                                    showPaywall = true
                                }
                            },
                            actionLabel: "Add Pet"
                        )

                        ForEach(pets) { pet in
                            NavigationLink(value: pet) {
                                PetRow(pet: pet, nextTrip: nextTripPerPet[pet.id])
                            }
                            .buttonStyle(.plain)
                        }

                        if !pets.isEmpty && !gate.isPetCreationAllowed(currentCount: pets.count, isPro: store.isPro) {
                            ProGateBanner(
                                title: "Add more pets with Pro",
                                message: "Free plan includes 1 pet."
                            ) { showPaywall = true }
                        }
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
        .navigationDestination(for: Pet.self) { pet in
            PetDetailScreen(pet: pet)
        }
        .sheet(isPresented: $showCreate) { PetCreateScreen() }
        .sheet(isPresented: $showPaywall) { PaywallScreen() }
    }
}

private struct PetRow: View {
    let pet: Pet
    let nextTrip: Trip?

    var body: some View {
        HStack(spacing: 14) {
            PetAvatar(pet: pet)
            VStack(alignment: .leading, spacing: 5) {
                Text(pet.name)
                    .font(.headline)
                Text("\(pet.species.label) · \(pet.breed)")
                    .font(.subheadline)
                    .foregroundStyle(Color.appMuted)
                if let trip = nextTrip {
                    HStack(spacing: 6) {
                        Image(systemName: "airplane.departure")
                            .font(.caption2.weight(.bold))
                        Text("\(trip.daysUntilEntry > 0 ? "In \(trip.daysUntilEntry)d" : "Today") · \(CountryService.shared.country(byCode: trip.destinationCountryCode)?.flag ?? "")")
                            .font(.caption.weight(.bold))
                    }
                    .foregroundStyle(Color.appBrand)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.appBrandLight, in: Capsule())
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.appMuted.opacity(0.6))
        }
        .appCard()
    }
}
