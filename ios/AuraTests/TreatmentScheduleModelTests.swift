import XCTest
import SwiftData
@testable import Aura

final class TreatmentScheduleModelTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!

    override func setUpWithError() throws {
        container = try makeContainer()
        context = ModelContext(container)
        context.autosaveEnabled = false
    }

    func testDefaultValues() {
        let schedule = TreatmentSchedule()
        XCTAssertEqual(schedule.timesPerDay, 1)
        XCTAssertTrue(schedule.isActive)
        XCTAssertNil(schedule.medicine)
    }

    func testDeletingMedicineCascadesToSchedule() throws {
        let medicine = Medicine(name: "Propranolol", sfSymbol: "pills.fill")
        let schedule = TreatmentSchedule(medicine: medicine, timesPerDay: 1)
        context.insert(medicine)
        context.insert(schedule)
        try context.save()

        context.delete(medicine)
        try context.save()

        let schedules = try context.fetch(FetchDescriptor<TreatmentSchedule>())
        XCTAssertTrue(schedules.isEmpty, "TreatmentSchedule should be deleted when its medicine is deleted")
    }
}
