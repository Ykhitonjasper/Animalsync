import SwiftUI

struct AppNavigationTitle: View {
    let title: String
    var subtitle: String? = nil
    var badge: String? = nil
    var action: (() -> Void)? = nil
    var actionLabel: String = "Add"

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(title)
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(Color.appText)
                    if let badge {
                        Text(badge)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.appBrand)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.appBrandLight, in: Capsule())
                    }
                }
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color.appMuted)
                }
            }
            Spacer(minLength: 12)
            if let action {
                AppToolbarAddButton(action: action, label: actionLabel)
            }
        }
        .padding(.top, AppTheme.spacingSM)
        .padding(.bottom, AppTheme.spacingXS)
    }
}
