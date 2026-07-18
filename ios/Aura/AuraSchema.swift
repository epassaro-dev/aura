import SwiftData

enum AuraSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
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
        ]
    }
}

enum AuraMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [AuraSchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}
