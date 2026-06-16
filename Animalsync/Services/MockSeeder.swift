import Foundation
import SwiftData

enum MockSeeder {
    static func seed(into context: ModelContext) {
        let pets = MockData.pets()
        let trips = MockData.trips()
        let documents = MockData.documents()

        pets.forEach { context.insert($0) }
        trips.forEach { context.insert($0) }
        documents.forEach { context.insert($0) }

        MockAssetInstaller.install(pets: pets, documents: documents)
        try? context.save()
    }
}
