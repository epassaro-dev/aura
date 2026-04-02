import XCTest
import SwiftData
@testable import Aura

// MARK: - Base test case with in-memory SwiftData container

class AuraTestCase: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext:   ModelContext { modelContainer.mainContext }

    override func setUpWithError() throws {
        try super.setUpWithError()
        let schema = Schema([
            DailyLog.self,
            SleepEntry.self,
            MedicationEntry.self,
            ActivityEntry.self,
            FoodEntry.self,
            Note.self,
            MigraineEpisode.self,
        ])
        modelContainer = try ModelContainer(
            for: schema,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }

    override func tearDownWithError() throws {
        modelContainer = nil
        try super.tearDownWithError()
    }
}
