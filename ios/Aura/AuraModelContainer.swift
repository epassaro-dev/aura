import SwiftData

extension ModelContainer {
    static func makeAuraContainer(inMemory: Bool = false) throws -> ModelContainer {
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
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        return try ModelContainer(for: schema, configurations: [config])
    }
}
