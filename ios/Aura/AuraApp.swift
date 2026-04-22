import SwiftUI
import SwiftData

@main
struct AuraApp: App {
    let modelContainer: ModelContainer = {
        let schema = Schema([
            FeelingType.self,
            TriggerType.self,
            SymptomType.self,
            Medicine.self,
            FoodItem.self,
            ActivityType.self,
            TellingSignType.self,
            ReliefMethodType.self,
            SleepEntry.self,
            FeelingEntry.self,
            MedicineLog.self,
            ActivityEntry.self,
            MealEntry.self,
            TriggerEntry.self,
            SymptomEntry.self,
            HeadacheEntry.self,
            HeadachePainLog.self,
            HeadacheSymptomLog.self,
            HeadacheMedicineLog.self,
            HeadacheReliefLog.self,
            TreatmentSchedule.self,
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            DataSeeder.seed(context: container.mainContext)
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
