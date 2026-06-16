import Foundation
import SwiftData

enum NotificationCoordinator {
    static func sync(
        trips: [Trip],
        pets: [Pet],
        enabled: Bool,
        leadDays: Int
    ) async {
        if !enabled {
            NotificationScheduler.cancelAll()
            return
        }

        let authorized = await NotificationScheduler.requestAuthorization()
        guard authorized else { return }

        NotificationScheduler.cancelAll()

        let petMap = Dictionary(uniqueKeysWithValues: pets.map { ($0.id, $0) })
        for trip in trips where trip.status != .past {
            guard let pet = petMap[trip.petID] else { continue }
            let tasks = TimelineEngine.tasks(for: trip, pet: pet)
            for task in tasks where !task.isCompleted && task.status != .done {
                await NotificationScheduler.schedule(task: task, leadDays: leadDays)
            }
        }
    }

    static func syncFromContext(
        _ context: ModelContext,
        enabled: Bool,
        leadDays: Int
    ) async {
        let tripDescriptor = FetchDescriptor<Trip>()
        let petDescriptor = FetchDescriptor<Pet>()
        guard let trips = try? context.fetch(tripDescriptor),
              let pets = try? context.fetch(petDescriptor) else { return }
        await sync(trips: trips, pets: pets, enabled: enabled, leadDays: leadDays)
    }
}
