import SwiftUI

struct WizardStepHeader: View {
    let step: Int
    let total: Int
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                ForEach(0..<total, id: \.self) { index in
                    Capsule()
                        .fill(index < step ? AnyShapeStyle(AppTheme.brandGradient) : AnyShapeStyle(Color.appBorder))
                        .frame(height: 5)
                }
            }
            HStack {
                Text("Step \(step) of \(total)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.appBrand)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.appBrandLight, in: Capsule())
                Spacer()
            }
            Text(title)
                .font(.title.weight(.bold))
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(Color.appMuted)
                .lineSpacing(2)
        }
        .appCard()
    }
}
