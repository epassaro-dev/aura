import SwiftUI
import SwiftData

@main
struct AuraApp: App {
    @Environment(\.scenePhase) private var scenePhase

    // ViewModels created at app level so the ModelContext is available immediately.
    @StateObject private var dailyLogViewModel:  DailyLogViewModel
    @StateObject private var settingsViewModel:  SettingsViewModel
    @StateObject private var securityViewModel:  SecurityViewModel

    let modelContainer: ModelContainer

    init() {
        do {
            let schema = Schema([
                DailyLog.self,
                SleepEntry.self,
                MedicationEntry.self,
                ActivityEntry.self,
                FoodEntry.self,
                Note.self,
                MigraineEpisode.self,
            ])
            let config    = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            let container = try ModelContainer(for: schema, configurations: [config])
            modelContainer = container

            _dailyLogViewModel = StateObject(
                wrappedValue: DailyLogViewModel(modelContext: container.mainContext)
            )
            _settingsViewModel = StateObject(wrappedValue: SettingsViewModel())
            _securityViewModel = StateObject(wrappedValue: SecurityViewModel())
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if securityViewModel.isLocked {
                    LockScreenView()
                        .environmentObject(securityViewModel)
                } else {
                    ContentView()
                        .environmentObject(dailyLogViewModel)
                        .environmentObject(settingsViewModel)
                        .environmentObject(securityViewModel)
                }
            }
        }
        .modelContainer(modelContainer)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                securityViewModel.lockIfNeeded()
            }
        }
    }
}
