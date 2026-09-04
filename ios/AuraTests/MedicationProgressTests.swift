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
        let aspirin = Medicine(name: "Aspirin")
        let ibuprofen = Medicine(name: "Ibuprofen")
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

    // MARK: - isCompleted

    func testIsCompletedOnlyWhenAllDosesTaken() throws {
        let medicine = Medicine(name: "Aspirin")
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
}
