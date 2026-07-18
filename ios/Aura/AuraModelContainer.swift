import SwiftData

extension ModelContainer {
    static func makeAuraContainer(inMemory: Bool = false) throws -> ModelContainer {
        let schema = Schema(versionedSchema: AuraSchemaV1.self)
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        return try ModelContainer(for: schema, migrationPlan: AuraMigrationPlan.self, configurations: [config])
    }
}
