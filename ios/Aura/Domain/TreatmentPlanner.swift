import Foundation

/// Domain rules for treatment plans, dose logging, and the medicine
/// catalog. Builds or mutates models only — every ModelContext write
/// (insert/save) belongs to the caller.
enum TreatmentPlanner {
    /// Enforces "one active plan per medicine": deactivates the existing
    /// active plans in place and returns the replacement for the caller
    /// to insert.
    static func replacePlan(for medicine: Medicine, dosage: Dosage?, timesPerDay: Int) -> TreatmentPlan {
        for plan in medicine.plans where plan.isActive {
            plan.stop()
        }
        return TreatmentPlan(medicine: medicine, dosage: dosage, timesPerDay: timesPerDay)
    }

    /// Builds one dose log taken now, anchored to today, or nil once the
    /// plan is completed.
    static func doseLog(
        for plan: TreatmentPlan,
        progress: MedicationProgress,
        now: Date = .now,
        calendar: Calendar = .current
    ) -> MedicineLog? {
        let medicine = plan.medicine
        guard !progress.isCompleted(for: plan) else { return nil }
        return MedicineLog(
            date: calendar.startOfDay(for: now),
            timestamp: now,
            medicine: medicine,
            dosage: plan.dosage ?? medicine.defaultDosage
        )
    }
}
