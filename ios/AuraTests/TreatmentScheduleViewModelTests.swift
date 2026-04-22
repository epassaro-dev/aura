import XCTest
import SwiftData
@testable import Aura

final class TreatmentScheduleViewModelTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!

    override func setUpWithError() throws {
        container = try makeContainer()
        context = ModelContext(container)
        context.autosaveEnabled = false
    }

    func testSaveCreatesActiveSchedule() throws {
        let medicine = Medicine(name: "Propranolol", sfSymbol: "pills.fill")
        context.insert(medicine)
        try context.save()

        let vm = TreatmentScheduleViewModel(context: context, medicine: medicine)
        vm.timesPerDay = 2
        vm.save()

        let schedules = try context.fetch(FetchDescriptor<TreatmentSchedule>())
        XCTAssertEqual(schedules.count, 1)
        XCTAssertEqual(schedules.first?.timesPerDay, 2)
        XCTAssertTrue(schedules.first?.isActive == true)
    }

    func testSaveDeactivatesPreviousSchedule() throws {
        let medicine = Medicine(name: "Propranolol", sfSymbol: "pills.fill")
        let existing = TreatmentSchedule(medicine: medicine, timesPerDay: 1)
        context.insert(medicine)
        context.insert(existing)
        try context.save()

        let vm = TreatmentScheduleViewModel(context: context, medicine: medicine)
        vm.timesPerDay = 3
        vm.save()

        let schedules = try context.fetch(FetchDescriptor<TreatmentSchedule>())
        XCTAssertEqual(schedules.count, 2)
        let active = schedules.filter { $0.isActive }
        XCTAssertEqual(active.count, 1)
        XCTAssertEqual(active.first?.timesPerDay, 3)
    }
}
