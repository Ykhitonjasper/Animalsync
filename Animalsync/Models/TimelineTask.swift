import Foundation

struct TimelineTask: Identifiable, Hashable {
    let id: UUID
    let requirementID: String
    let title: String
    let descriptionText: String
    let type: RequirementType
    let earliestDate: Date
    let deadlineDate: Date
    let status: TaskStatus
    let countryCode: String
    let countryFlag: String
    let isCompleted: Bool
    let linkedDocumentID: UUID?

    var daysUntilDeadline: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: deadlineDate).day ?? 0
    }

    var dateOffsetLabel: String {
        let days = daysUntilDeadline
        if days < 0 { return "\(-days) days ago" }
        if days == 0 { return "Today" }
        if days == 1 { return "Tomorrow" }
        return "in \(days) days"
    }
}
