import SwiftUI
import SwiftData

@main
struct AnimalsyncApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Pet.self, Trip.self, PetDocument.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        _ = StoreKitManager.shared
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
    }
}
