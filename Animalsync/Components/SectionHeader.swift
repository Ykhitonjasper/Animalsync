import SwiftUI

struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var trailing: AnyView? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title.uppercased())
                    .font(.caption.weight(.bold))
                    .tracking(0.6)
                    .foregroundStyle(Color.appBrand)
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.appMuted)
                }
            }
            Spacer()
            trailing
        }
        .padding(.vertical, AppTheme.spacingXS)
    }
}
