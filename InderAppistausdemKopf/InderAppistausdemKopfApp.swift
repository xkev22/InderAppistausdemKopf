import SwiftUI
import SwiftData

@main
struct InderAppistausdemKopfApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ListItem.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema, 
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none // Lokale Speicherung ohne CloudKit
        )
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
