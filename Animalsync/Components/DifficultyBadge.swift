import SwiftUI

struct DifficultyBadge: View {
    let difficulty: Difficulty

    var body: some View {
        Text(difficulty.label.uppercased())
            .font(.caption2.weight(.bold))
            .tracking(0.4)
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(difficulty.tint.opacity(0.14), in: Capsule())
            .overlay(Capsule().strokeBorder(difficulty.tint.opacity(0.28), lineWidth: 0.5))
            .foregroundStyle(difficulty.tint)
            .accessibilityLabel("Difficulty: \(difficulty.label)")
    }
}
