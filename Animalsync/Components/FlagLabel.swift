import SwiftUI

struct FlagLabel: View {
    let code: String
    var compact: Bool = false

    private var country: CountryRequirement? {
        CountryService.shared.country(byCode: code)
    }

    var body: some View {
        HStack(spacing: 8) {
            Text(country?.flag ?? "🏳️")
                .font(compact ? .body : .title)
            if !compact {
                VStack(alignment: .leading, spacing: 1) {
                    Text(country?.name ?? code)
                        .font(.subheadline.weight(.bold))
                    Text(code)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Color.appMuted)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(country?.name ?? code)
    }
}
