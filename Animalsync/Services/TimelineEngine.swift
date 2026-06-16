import Foundation

enum TimelineEngine {
    static func tasks(for trip: Trip, pet: Pet) -> [TimelineTask] {
        let service = CountryService.shared
        let route = [trip.destinationCountryCode] + trip.transitCountryCodes
        let countries = route.compactMap { service.country(byCode: $0) }
        let today = Calendar.current.startOfDay(for: Date())
        let entry = Calendar.current.startOfDay(for: trip.entryDate)
        let completedSet = Set(trip.completedRequirementIDs)

        var seenIDs = Set<String>()
        var tasks: [TimelineTask] = []

        for country in countries {
            for req in country.requirements(for: pet.species) {
                guard !seenIDs.contains(req.stableID) else { continue }
                seenIDs.insert(req.stableID)

                let earliest = Calendar.current.date(
                    byAdding: .day, value: -req.daysBeforeEntryMin, to: entry
                ) ?? entry
                let deadline = Calendar.current.date(
                    byAdding: .day, value: -req.daysBeforeEntryMax, to: entry
                ) ?? entry

                let isCompleted = completedSet.contains(req.stableID)
                let status: TaskStatus
                if isCompleted {
                    status = .done
                } else if deadline < today {
                    status = .overdue
                } else if Calendar.current.dateComponents([.day], from: today, to: deadline).day ?? 0 <= 7 {
                    status = .dueSoon
                } else {
                    status = .scheduled
                }

                let linkedID: UUID? = {
                    guard let raw = trip.requirementDocumentLinks[req.stableID] else { return nil }
                    return UUID(uuidString: raw)
                }()

                tasks.append(TimelineTask(
                    id: UUID(),
                    requirementID: req.stableID,
                    title: req.title,
                    descriptionText: req.descriptionText,
                    type: req.type,
                    earliestDate: earliest,
                    deadlineDate: deadline,
                    status: status,
                    countryCode: country.code,
                    countryFlag: country.flag,
                    isCompleted: isCompleted,
                    linkedDocumentID: linkedID
                ))
            }
        }

        return tasks.sorted { $0.deadlineDate < $1.deadlineDate }
    }
}
