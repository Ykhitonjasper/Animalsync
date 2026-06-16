import SwiftUI

struct DateOffsetLabel: View {
    let date: Date
    let entryDate: Date

    private var daysBeforeEntry: Int {
        Calendar.current.dateComponents([.day], from: date, to: entryDate).day ?? 0
    }

    var body: some View {
        let prefix = daysBeforeEntry > 0 ? "\(daysBeforeEntry) days before entry" : "After entry"
        Text("\(prefix) · \(date.formatted(date: .abbreviated, time: .omitted))")
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}
