import SwiftUI

struct ProGateBanner: View {
    let title: String
    let message: String
    var onUpgrade: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            AppIconBadge(symbol: "sparkles", size: 44, tint: .appGold)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                Text(message)
                    .font(.caption)
                    .foregroundStyle(Color.appMuted)
            }
            Spacer(minLength: 8)
            Button {
                Haptic.medium()
                onUpgrade()
            } label: {
                Text("Upgrade")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(AppTheme.actionGradient, in: Capsule())
            }
        }
        .glassBg()
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.radiusMD, style: .continuous)
                .strokeBorder(Color.appGold.opacity(0.35), lineWidth: 1)
        )
    }
}
