import Foundation
import SwiftData

/// Derived, display-ready view of today's treatment plans and dose logs.
struct MedicationProgress {
    let plans: [TreatmentPlan]
    let logs: [MedicineLog]

    func takenCount(for plan: TreatmentPlan) -> Int {
        let medicine = plan.medicine
        let medicineID = medicine.persistentModelID
        return logs.filter { $0.medicine.persistentModelID == medicineID }.count
    }

    func isCompleted(for plan: TreatmentPlan) -> Bool {
        takenCount(for: plan) >= plan.timesPerDay
    }
}
