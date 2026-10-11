import XCTest
import SwiftData
@testable import Aura

final class TreatmentPlanModelTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!

    override func setUpWithError() throws {
        container = try makeContainer()
        context = ModelContext(container)
        context.autosaveEnabled = false
    }

    func testDefaultValues() {
        let medicine = Medicine(name: "Propranolol")
        let plan = TreatmentPlan(medicine: medicine)
        XCTAssertEqual(plan.timesPerDay, 1)
        XCTAssertNil(plan.endDate)
        XCTAssertTrue(plan.isActive)
    }

    func testStopPlanIsActiveReturnsFalse() {
        let medicine = Medicine(name: "Propranolol")
        let plan = TreatmentPlan(medicine: medicine)
        XCTAssertTrue(plan.isActive)

        plan.stop()
        XCTAssertNotNil(plan.endDate)
        XCTAssertFalse(plan.isActive)
    }

    func testDeletingMedicineWithTreatmentPlanIsDenied() throws {
        let medicine = Medicine(name: "Propranolol")
        let plan = TreatmentPlan(medicine: medicine, timesPerDay: 1)
        context.insert(medicine)
        context.insert(plan)
        try context.save()

        context.delete(medicine)
        XCTAssertThrowsError(try context.save(), "Cannot delete a medicine that has a treatment plan")
    }

    // MARK: - scheduleString

    func testScheduleStringOnceADay() {
        let medicine = Medicine(name: "Propranolol")
        let plan = TreatmentPlan(medicine: medicine, timesPerDay: 1)
        XCTAssertEqual(plan.scheduleString(), "Once per day")
    }

    func testScheduleStringTwiceADay() {
        let medicine = Medicine(name: "Propranolol")
        let plan = TreatmentPlan(medicine: medicine, timesPerDay: 2)
        XCTAssertEqual(plan.scheduleString(), "Twice per day")
    }

    func testScheduleStringMultipleTimesADay() {
        let medicine = Medicine(name: "Propranolol")
        let plan = TreatmentPlan(medicine: medicine, timesPerDay: 4)
        XCTAssertEqual(plan.scheduleString(), "4 times per day")
    }

    // MARK: - dosageString

    func testDosageStringUsesPlanDosageWhenSet() {
        let medicine = Medicine(name: "Propranolol", defaultDosage: Dosage(amount: "20", unit: .mg))
        let plan = TreatmentPlan(medicine: medicine, dosage: Dosage(amount: "40", unit: .mg))
        XCTAssertEqual(plan.dosageString(), "40 mg")
    }

    func testDosageStringFallsBackToMedicineDefaultDosage() {
        let medicine = Medicine(name: "Propranolol", defaultDosage: Dosage(amount: "20", unit: .mg))
        let plan = TreatmentPlan(medicine: medicine)
        XCTAssertEqual(plan.dosageString(), "20 mg")
    }

    func testDosageStringIsEmptyWhenNoDosageAvailable() {
        let medicine = Medicine(name: "Propranolol")
        let plan = TreatmentPlan(medicine: medicine)
        XCTAssertEqual(plan.dosageString(), "")
    }
}
