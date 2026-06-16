import SwiftUI

struct TimelineTaskRow: View {
    let task: TimelineTask
    let entryDate: Date
    var onToggle: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            timelineNode
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: task.type.icon)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(Color.appBrand)
                            Text(task.title)
                                .font(.subheadline.weight(.bold))
                        }
                        Text(task.countryFlag)
                            .font(.caption)
                    }
                    Spacer()
                    StatusPill(status: task.status)
                }

                Text(task.descriptionText)
                    .font(.caption)
                    .foregroundStyle(Color.appMuted)
                    .lineLimit(3)
                    .lineSpacing(2)

                HStack {
                    DateOffsetLabel(date: task.deadlineDate, entryDate: entryDate)
                    if task.linkedDocumentID != nil {
                        Label("Proof", systemImage: "paperclip")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.green)
                    }
                }

                if let onToggle {
                    Button(action: onToggle) {
                        Label(
                            task.isCompleted ? "Mark as not done" : "Mark as done",
                            systemImage: task.isCompleted ? "arrow.uturn.backward" : "checkmark.circle.fill"
                        )
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.appBrand)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 2)
                }
            }
            .appCard(padding: AppTheme.spacingSM + 2)
        }
    }

    private var timelineNode: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(task.status.tint.opacity(0.15))
                    .frame(width: 34, height: 34)
                Circle()
                    .strokeBorder(task.status.tint, lineWidth: 2)
                    .frame(width: 34, height: 34)
                Image(systemName: task.status.icon)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(task.status.tint)
            }
            Rectangle()
                .fill(Color.appBorder)
                .frame(width: 2)
                .frame(maxHeight: .infinity)
        }
        .frame(width: 34)
    }
}
