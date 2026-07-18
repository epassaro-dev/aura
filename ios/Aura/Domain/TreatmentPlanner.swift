import Foundation

/// Domain rules for treatment schedules, dose logging, and the medicine
/// catalog. Builds or mutates models only — every ModelContext write
/// (insert/save) belongs to the caller.
enum TreatmentPlanner {
    /// Enforces "one active schedule per medicine": deactivates the existing
    /// active schedules in place and returns the replacement for the caller
    /// to insert.
    static func replaceSchedule(for medicine: Medicine, timesPerDay: Int) -> TreatmentSchedule {
        for schedule in medicine.schedules where schedule.isActive {
            schedule.isActive = false
        }
        return TreatmentSchedule(medicine: medicine, timesPerDay: timesPerDay)
    }

    /// Builds one dose log taken now, anchored to today, or nil once the
    /// schedule is completed.
    static func doseLog(
        for schedule: TreatmentSchedule,
        progress: MedicationProgress,
        now: Date = .now,
        calendar: Calendar = .current
    ) -> MedicineLog? {
        guard let medicine = schedule.medicine, !progress.isCompleted(for: schedule) else { return nil }
        return MedicineLog(
            date: calendar.startOfDay(for: now),
            timestamp: now,
            medicine: medicine,
            dosage: medicine.defaultDosage
        )
    }

    /// Builds a custom medicine, or nil for a blank name. Blank dosages become nil.
    static func makeMedicine(name: String, defaultDosage: String?) -> Medicine? {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return nil }
        let trimmedDosage = defaultDosage?.trimmingCharacters(in: .whitespaces)
        let finalDosage = (trimmedDosage?.isEmpty == false) ? trimmedDosage : nil
        return Medicine(name: trimmedName, sfSymbol: "pills.fill", defaultDosage: finalDosage)
    }
}
