import XCTest
import SwiftData
@testable import Aura

final class MedicationProgressTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!

    override func setUpWithError() throws {
        container = try makeContainer()
        context = ModelContext(container)
        context.autosaveEnabled = false
    }

    private func makeLog(for medicine: Medicine) -> MedicineLog {
        let today = Calendar.current.startOfDay(for: .now)
        return MedicineLog(date: today, timestamp: .now, medicine: medicine, dosage: nil)
    }

    // MARK: - takenCount

    func testTakenCountCountsOnlyMatchingMedicine() throws {
        let aspirin = Medicine(name: "Aspirin", sfSymbol: "pills.fill")
        let ibuprofen = Medicine(name: "Ibuprofen", sfSymbol: "pills.fill")
        let schedule = TreatmentSchedule(medicine: aspirin, timesPerDay: 2)
        context.insert(aspirin)
        context.insert(ibuprofen)
        context.insert(schedule)
        let logs = [makeLog(for: aspirin), makeLog(for: ibuprofen)]
        logs.forEach { context.insert($0) }
        try context.save()

        let progress = MedicationProgress(schedules: [schedule], logs: logs)
        XCTAssertEqual(progress.takenCount(for: schedule), 1)
    }

    func testTakenCountIsZeroWithoutMedicine() throws {
        let schedule = TreatmentSchedule(medicine: nil, timesPerDay: 1)
        context.insert(schedule)
        try context.save()

        let progress = MedicationProgress(schedules: [schedule], logs: [])
        XCTAssertEqual(progress.takenCount(for: schedule), 0)
        XCTAssertFalse(progress.isCompleted(for: schedule))
    }

    // MARK: - isCompleted

    func testIsCompletedOnlyWhenAllDosesTaken() throws {
        let medicine = Medicine(name: "Aspirin", sfSymbol: "pills.fill")
        let schedule = TreatmentSchedule(medicine: medicine, timesPerDay: 2)
        context.insert(medicine)
        context.insert(schedule)
        let firstDose = makeLog(for: medicine)
        context.insert(firstDose)
        try context.save()

        XCTAssertFalse(MedicationProgress(schedules: [schedule], logs: [firstDose]).isCompleted(for: schedule))

        let secondDose = makeLog(for: medicine)
        context.insert(secondDose)
        try context.save()

        let progress = MedicationProgress(schedules: [schedule], logs: [firstDose, secondDose])
        XCTAssertTrue(progress.isCompleted(for: schedule))
    }

    // MARK: - displaySchedules

    func testDisplaySchedulesExcludesNilMedicine() throws {
        let medicine = Medicine(name: "Aspirin", sfSymbol: "pills.fill")
        let valid = TreatmentSchedule(medicine: medicine, timesPerDay: 1)
        let orphan = TreatmentSchedule(medicine: nil, timesPerDay: 1)
        context.insert(medicine)
        context.insert(valid)
        context.insert(orphan)
        try context.save()

        let progress = MedicationProgress(schedules: [valid, orphan], logs: [])
        XCTAssertEqual(progress.displaySchedules.count, 1)
    }

    func testDisplaySchedulesExcludesArchivedMedicine() throws {
        let archived = Medicine(name: "OldMed", sfSymbol: "pills.fill", isArchived: true)
        let schedule = TreatmentSchedule(medicine: archived, timesPerDay: 1)
        context.insert(archived)
        context.insert(schedule)
        try context.save()

        let progress = MedicationProgress(schedules: [schedule], logs: [])
        XCTAssertTrue(progress.displaySchedules.isEmpty)
    }
}
