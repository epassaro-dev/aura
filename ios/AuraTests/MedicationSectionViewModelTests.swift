import XCTest
import SwiftData
@testable import Aura

final class MedicationSectionViewModelTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!

    override func setUpWithError() throws {
        container = try makeContainer()
        context = ModelContext(container)
        context.autosaveEnabled = false
    }

    func testMarkTakenIncrementsCount() throws {
        let medicine = Medicine(name: "Ibuprofen", sfSymbol: "pills.fill")
        let schedule = TreatmentSchedule(medicine: medicine, timesPerDay: 2)
        context.insert(medicine)
        context.insert(schedule)
        try context.save()

        let vm = MedicationSectionViewModel(context: context)
        XCTAssertEqual(vm.takenCount(for: schedule), 0)

        vm.markTaken(for: schedule)
        XCTAssertEqual(vm.takenCount(for: schedule), 1)
    }

    func testIsCompletedAfterAllDosesTaken() throws {
        let medicine = Medicine(name: "Aspirin", sfSymbol: "pills.fill")
        let schedule = TreatmentSchedule(medicine: medicine, timesPerDay: 2)
        context.insert(medicine)
        context.insert(schedule)
        try context.save()

        let vm = MedicationSectionViewModel(context: context)
        vm.markTaken(for: schedule)
        XCTAssertFalse(vm.isCompleted(for: schedule))
        vm.markTaken(for: schedule)
        XCTAssertTrue(vm.isCompleted(for: schedule))
    }

    func testMarkTakenIsNoopWhenCompleted() throws {
        let medicine = Medicine(name: "Aspirin", sfSymbol: "pills.fill")
        let schedule = TreatmentSchedule(medicine: medicine, timesPerDay: 1)
        context.insert(medicine)
        context.insert(schedule)
        try context.save()

        let vm = MedicationSectionViewModel(context: context)
        vm.markTaken(for: schedule)
        vm.markTaken(for: schedule)
        XCTAssertEqual(vm.takenCount(for: schedule), 1)
    }

    func testSchedulesWithNoMedicineHaveZeroCount() throws {
        let schedule = TreatmentSchedule(medicine: nil, timesPerDay: 1)
        context.insert(schedule)
        try context.save()

        let vm = MedicationSectionViewModel(context: context)
        XCTAssertEqual(vm.takenCount(for: schedule), 0)
        XCTAssertFalse(vm.isCompleted(for: schedule))
    }
}
