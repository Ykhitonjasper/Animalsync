import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: AppTheme.spacingLG) {
            AppIconBadge(symbol: icon, size: 88, tint: .appBrand)
            VStack(spacing: AppTheme.spacingSM) {
                Text(title)
                    .font(.title2.weight(.bold))
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(Color.appMuted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                }
                .buttonStyle(AppPrimaryButtonStyle())
                .padding(.horizontal, AppTheme.spacingXL)
                .padding(.top, AppTheme.spacingSM)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(AppTheme.spacingLG)
    }
}
