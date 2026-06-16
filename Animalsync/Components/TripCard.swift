import SwiftUI

struct TripCard: View {
    let trip: Trip
    let pet: Pet?
    var dimmed: Bool = false

    private var destination: CountryRequirement? {
        CountryService.shared.country(byCode: trip.destinationCountryCode)
    }

    private var accentColor: Color {
        switch trip.status {
        case .ready: .green
        case .blocked: .red
        case .planning: .appBrand
        case .past: .secondary
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                FlagLabel(code: trip.destinationCountryCode)
                Spacer()
                TripStatusPill(status: trip.status)
            }

            if let pet {
                HStack(spacing: 8) {
                    PetAvatar(pet: pet, size: 28)
                    Text(pet.name)
                        .font(.subheadline.weight(.semibold))
                    if !trip.transitCountryCodes.isEmpty {
                        Image(systemName: "arrow.right")
                            .font(.caption2)
                            .foregroundStyle(Color.appMuted)
                        Text(trip.transitCountryCodes.map {
                            CountryService.shared.country(byCode: $0)?.flag ?? $0
                        }.joined(separator: " "))
                        .font(.subheadline)
                    }
                }
            }

            Divider().overlay(Color.appBorder)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    if trip.status == .past {
                        Text("Completed")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.appMuted)
                        Text(trip.entryDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else if trip.daysUntilEntry >= 0 {
                        Text("Departure countdown")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.appMuted)
                        Text("\(trip.daysUntilEntry) days left")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Color.appBrand)
                    } else {
                        Text(trip.entryDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                if let d = destination?.difficulty {
                    DifficultyBadge(difficulty: d)
                }
            }
        }
        .appAccentBar(accentColor)
        .padding(.leading, AppTheme.spacingSM)
        .appCard()
        .opacity(dimmed ? 0.65 : 1)
    }
}
