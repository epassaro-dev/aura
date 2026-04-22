import SwiftUI
import SwiftData

@main
struct AuraApp: App {
    let modelContainer: ModelContainer

    init() {
        let isTesting = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
        do {
            modelContainer = try .makeAuraContainer(inMemory: isTesting)
            if !isTesting {
                DataSeeder.seed(context: modelContainer.mainContext)
            }
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
