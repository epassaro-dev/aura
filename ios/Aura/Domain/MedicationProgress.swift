import Foundation
import SwiftData

/// Derived, display-ready view of today's treatment schedules and dose logs.
struct MedicationProgress {
    let schedules: [TreatmentSchedule]
    let logs: [MedicineLog]

    func takenCount(for schedule: TreatmentSchedule) -> Int {
        let medicine = schedule.medicine
        let medicineID = medicine.persistentModelID
        return logs.filter { $0.medicine.persistentModelID == medicineID }.count
    }

    func isCompleted(for schedule: TreatmentSchedule) -> Bool {
        takenCount(for: schedule) >= schedule.timesPerDay
    }
}
