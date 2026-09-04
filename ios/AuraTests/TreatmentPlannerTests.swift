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

    private func progress(for plan: TreatmentPlan) throws -> MedicationProgress {
        MedicationProgress(plans: [plan], logs: try fetchLogs())
    }

    // MARK: - replacePlan

    func testReplacePlanBuildsActivePlan() throws {
        let medicine = Medicine(name: "Propranolol")
        context.insert(medicine)
        try context.save()

        let treatmentDosage = Dosage(amount: "40", unit: .mg)
        let plan = TreatmentPlanner.replacePlan(for: medicine, dosage: treatmentDosage, timesPerDay: 2)
        context.insert(plan)
        try context.save()

        let plans = try context.fetch(FetchDescriptor<TreatmentPlan>())
        XCTAssertEqual(plans.count, 1)
        XCTAssertEqual(plans.first?.timesPerDay, 2)
        XCTAssertTrue(plans.first?.isActive == true)
        XCTAssertEqual(plans.first?.medicine.name, "Propranolol")
        XCTAssertEqual(plans.first?.dosage, treatmentDosage)
    }

    func testReplacePlanDeactivatesPreviousPlanInPlace() throws {
        let medicine = Medicine(name: "Propranolol")
        let existingDosage = Dosage(amount: "40", unit: .mg)
        let existing = TreatmentPlan(medicine: medicine, dosage: existingDosage, timesPerDay: 1)
        context.insert(medicine)
        context.insert(existing)
        try context.save()

        let replacementDosage = Dosage(amount: "80", unit: .mg)
        let replacement = TreatmentPlanner.replacePlan(for: medicine, dosage: replacementDosage, timesPerDay: 3)
        context.insert(replacement)
        try context.save()

        XCTAssertFalse(existing.isActive)
        let plans = try context.fetch(FetchDescriptor<TreatmentPlan>())
        XCTAssertEqual(plans.count, 2)
        let active = plans.filter { $0.isActive }
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
        let plan = TreatmentPlan(medicine: medicine, timesPerDay: 2)
        context.insert(medicine)
        context.insert(plan)
        try context.save()

        let log = try XCTUnwrap(TreatmentPlanner.doseLog(
            for: plan,
            progress: progress(for: plan),
            now: now,
            calendar: calendar
        ))

        XCTAssertEqual(log.date, calendar.startOfDay(for: now))
        XCTAssertEqual(log.timestamp, now)
        XCTAssertEqual(log.dosage, dosage)
    }

    func testDoseLogIsNilOnceCompleted() throws {
        let medicine = Medicine(name: "Aspirin")
        let plan = TreatmentPlan(medicine: medicine, timesPerDay: 1)
        context.insert(medicine)
        context.insert(plan)
        try context.save()

        let first = try XCTUnwrap(TreatmentPlanner.doseLog(for: plan, progress: progress(for: plan)))
        context.insert(first)
        try context.save()

        XCTAssertNil(TreatmentPlanner.doseLog(for: plan, progress: try progress(for: plan)))
        XCTAssertEqual(try fetchLogs().count, 1)
    }

    // MARK: - Medicine.archive

    func testArchiveDeactivatesActivePlans() throws {
        let medicine = Medicine(name: "Propranolol")
        let plan = TreatmentPlan(medicine: medicine, timesPerDay: 2)
        context.insert(medicine)
        context.insert(plan)
        try context.save()

        medicine.archive()
        try context.save()

        XCTAssertTrue(medicine.isArchived)
        XCTAssertFalse(plan.isActive)
    }
}
