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
        let medicine = Medicine(name: "Propranolol")
        let schedule = TreatmentSchedule(medicine: medicine)
        XCTAssertEqual(schedule.timesPerDay, 1)
        XCTAssertNil(schedule.endDate)
        XCTAssertTrue(schedule.isActive)
    }

    func testStopScheduleIsActiveReturnsFalse() {
        let medicine = Medicine(name: "Propranolol")
        let schedule = TreatmentSchedule(medicine: medicine)
        XCTAssertTrue(schedule.isActive)

        schedule.stop()
        XCTAssertNotNil(schedule.endDate)
        XCTAssertFalse(schedule.isActive)
    }

    func testDeletingMedicineWithTreatmentScheduleIsDenied() throws {
        let medicine = Medicine(name: "Propranolol")
        let schedule = TreatmentSchedule(medicine: medicine, timesPerDay: 1)
        context.insert(medicine)
        context.insert(schedule)
        try context.save()

        context.delete(medicine)
        XCTAssertThrowsError(try context.save(), "Cannot delete a medicine that has a treatment schedule")
    }
}
