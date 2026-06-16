import SwiftUI

struct IconTextRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var tint: Color = .appBrand

    var body: some View {
        HStack(spacing: 14) {
            AppIconBadge(symbol: icon, size: 40, tint: tint)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.body.weight(.semibold))
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color.appMuted)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.appMuted.opacity(0.7))
        }
        .contentShape(Rectangle())
    }
}
