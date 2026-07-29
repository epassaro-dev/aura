import XCTest
import SwiftData
@testable import Aura

final class TreatmentPlannerTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!

    override func setUpWithError() throws {
        container = try makeContainer()
        context = ModelContext(container)
        context.autosaveEnabled = false
    }

    private func fetchLogs() throws -> [MedicineLog] {
        try context.fetch(FetchDescriptor<MedicineLog>())
    }

    private func progress(for schedule: TreatmentSchedule) throws -> MedicationProgress {
        MedicationProgress(schedules: [schedule], logs: try fetchLogs())
    }

    // MARK: - replaceSchedule

    func testReplaceScheduleBuildsActiveSchedule() throws {
        let medicine = Medicine(name: "Propranolol")
        context.insert(medicine)
        try context.save()

        let treatmentDosage = Dosage(amount: "40", unit: .mg)
        let schedule = TreatmentPlanner.replaceSchedule(for: medicine, dosage: treatmentDosage, timesPerDay: 2)
        context.insert(schedule)
        try context.save()

        let schedules = try context.fetch(FetchDescriptor<TreatmentSchedule>())
        XCTAssertEqual(schedules.count, 1)
        XCTAssertEqual(schedules.first?.timesPerDay, 2)
        XCTAssertTrue(schedules.first?.isActive == true)
        XCTAssertEqual(schedules.first?.medicine.name, "Propranolol")
        XCTAssertEqual(schedules.first?.dosage, treatmentDosage)
    }

    func testReplaceScheduleDeactivatesPreviousScheduleInPlace() throws {
        let medicine = Medicine(name: "Propranolol")
        let existingDosage = Dosage(amount: "40", unit: .mg)
        let existing = TreatmentSchedule(medicine: medicine, dosage: existingDosage, timesPerDay: 1)
        context.insert(medicine)
        context.insert(existing)
        try context.save()

        let replacementDosage = Dosage(amount: "80", unit: .mg)
        let replacement = TreatmentPlanner.replaceSchedule(for: medicine, dosage: replacementDosage, timesPerDay: 3)
        context.insert(replacement)
        try context.save()

        XCTAssertFalse(existing.isActive)
        let schedules = try context.fetch(FetchDescriptor<TreatmentSchedule>())
        XCTAssertEqual(schedules.count, 2)
        let active = schedules.filter { $0.isActive }
        XCTAssertEqual(active.count, 1)
        XCTAssertEqual(active.first?.timesPerDay, 3)
        XCTAssertEqual(active.first?.dosage, replacementDosage)
    }

    // MARK: - doseLog

    func testDoseLogAnchorsToDayAndUsesDefaultDosage() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome")!
        let now = calendar.date(from: DateComponents(year: 2026, month: 7, day: 9, hour: 8, minute: 30))!
        let dosage = Dosage(amount: "40", unit: .mg)

        let medicine = Medicine(name: "Propranolol", defaultDosage: dosage)
        let schedule = TreatmentSchedule(medicine: medicine, timesPerDay: 2)
        context.insert(medicine)
        context.insert(schedule)
        try context.save()

        let log = try XCTUnwrap(TreatmentPlanner.doseLog(
            for: schedule,
            progress: progress(for: schedule),
            now: now,
            calendar: calendar
        ))

        XCTAssertEqual(log.date, calendar.startOfDay(for: now))
        XCTAssertEqual(log.timestamp, now)
        XCTAssertEqual(log.dosage, dosage)
    }

    func testDoseLogIsNilOnceCompleted() throws {
        let medicine = Medicine(name: "Aspirin")
        let schedule = TreatmentSchedule(medicine: medicine, timesPerDay: 1)
        context.insert(medicine)
        context.insert(schedule)
        try context.save()

        let first = try XCTUnwrap(TreatmentPlanner.doseLog(for: schedule, progress: progress(for: schedule)))
        context.insert(first)
        try context.save()

        XCTAssertNil(TreatmentPlanner.doseLog(for: schedule, progress: try progress(for: schedule)))
        XCTAssertEqual(try fetchLogs().count, 1)
    }

    // MARK: - Medicine.archive

    func testArchiveDeactivatesActiveSchedules() throws {
        let medicine = Medicine(name: "Propranolol")
        let schedule = TreatmentSchedule(medicine: medicine, timesPerDay: 2)
        context.insert(medicine)
        context.insert(schedule)
        try context.save()

        medicine.archive()
        try context.save()

        XCTAssertTrue(medicine.isArchived)
        XCTAssertFalse(schedule.isActive)
    }
}
