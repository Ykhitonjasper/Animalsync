import SwiftUI

struct CountryRow: View {
    let country: CountryRequirement
    var selected: Bool = false
    var showChevron: Bool = true

    var body: some View {
        HStack(spacing: 12) {
            Text(country.flag).font(.title)
            VStack(alignment: .leading, spacing: 2) {
                Text(country.name).font(.body)
                HStack(spacing: 6) {
                    DifficultyBadge(difficulty: country.difficulty)
                    LastUpdatedLabel(dateString: country.lastUpdated, compact: true)
                }
            }
            Spacer()
            if selected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.tint)
            } else if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
        .padding(.vertical, 4)
    }
}
