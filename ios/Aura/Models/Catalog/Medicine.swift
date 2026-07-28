import SwiftData

@Model final class Medicine {
    var name: String
    var sfSymbol: String
    var isArchived: Bool
    var defaultDosage: Dosage?

    @Relationship(deleteRule: .nullify, inverse: \MedicineLog.medicine)
    var medicineLogs: [MedicineLog] = []

    @Relationship(deleteRule: .nullify, inverse: \HeadacheMedicineLog.medicine)
    var headacheMedicineLogs: [HeadacheMedicineLog] = []

    @Relationship(deleteRule: .cascade, inverse: \TreatmentSchedule.medicine)
    var schedules: [TreatmentSchedule] = []

    init(name: String, sfSymbol: String, isArchived: Bool = false, defaultDosage: Dosage? = nil) {
        self.name = name
        self.sfSymbol = sfSymbol
        self.isArchived = isArchived
        self.defaultDosage = defaultDosage
    }
}

extension Medicine {
    /// Soft-deletes the medicine and retires any active treatment schedule with it,
    /// so archived medicines disappear from the daily plan while their logs remain.
    func archive() {
        isArchived = true
        for schedule in schedules where schedule.isActive {
            schedule.isActive = false
        }
    }
}
