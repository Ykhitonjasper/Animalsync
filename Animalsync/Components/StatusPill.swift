import SwiftUI

struct StatusPill: View {
    let status: TaskStatus

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: status.icon)
                .font(.caption2.weight(.bold))
            Text(status.label)
                .font(.caption.weight(.bold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(status.tint.opacity(0.14), in: Capsule())
        .overlay(Capsule().strokeBorder(status.tint.opacity(0.25), lineWidth: 0.5))
        .foregroundStyle(status.tint)
    }
}

struct TripStatusPill: View {
    let status: TripStatus

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: status.systemImage)
                .font(.caption2.weight(.bold))
            Text(status.label)
                .font(.caption.weight(.bold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(status.tint.opacity(0.14), in: Capsule())
        .overlay(Capsule().strokeBorder(status.tint.opacity(0.25), lineWidth: 0.5))
        .foregroundStyle(status.tint)
    }
}
