import SwiftUI

struct LastUpdatedLabel: View {
    let dateString: String
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.caption2)
            Text(compact ? "Updated \(dateString)" : "Data updated \(dateString)")
                .font(.caption2)
        }
        .foregroundStyle(.secondary)
        .accessibilityLabel("Data last updated \(dateString)")
    }
}
