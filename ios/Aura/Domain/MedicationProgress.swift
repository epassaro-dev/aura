import Foundation
import SwiftData

/// Derived, display-ready view of today's treatment schedules and dose logs.
struct MedicationProgress {
    let schedules: [TreatmentSchedule]
    let logs: [MedicineLog]

    /// Schedules worth showing: those whose medicine still exists and isn't archived.
    var displaySchedules: [TreatmentSchedule] {
        schedules.filter { schedule in
            guard let medicine = schedule.medicine else { return false }
            return !medicine.isArchived
        }
    }

    func takenCount(for schedule: TreatmentSchedule) -> Int {
        guard let medicine = schedule.medicine else { return 0 }
        let medicineID = medicine.persistentModelID
        return logs.filter { $0.medicine?.persistentModelID == medicineID }.count
    }

    func isCompleted(for schedule: TreatmentSchedule) -> Bool {
        takenCount(for: schedule) >= schedule.timesPerDay
    }
}
