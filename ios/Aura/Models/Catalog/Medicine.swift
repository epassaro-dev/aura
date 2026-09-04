import SwiftData

@Model final class Medicine {
    var name: String
    var sfSymbol: String
    var isArchived: Bool
    var defaultDosage: Dosage?

    @Relationship(deleteRule: .deny, inverse: \MedicineLog.medicine)
    var medicineLogs: [MedicineLog] = []

    @Relationship(deleteRule: .deny, inverse: \HeadacheMedicineLog.medicine)
    var headacheMedicineLogs: [HeadacheMedicineLog] = []

    @Relationship(deleteRule: .deny, inverse: \TreatmentPlan.medicine)
    var plans: [TreatmentPlan] = []

    init(name: String, sfSymbol: String = "pills.fill", isArchived: Bool = false, defaultDosage: Dosage? = nil) {
        self.name = name
        self.sfSymbol = sfSymbol
        self.isArchived = isArchived
        self.defaultDosage = defaultDosage
    }
}

extension Medicine {
    /// Soft-deletes the medicine and retires any active treatment plan with it,
    /// so archived medicines disappear from the daily plan while their logs remain.
    func archive() {
        isArchived = true
        for plan in plans where plan.isActive {
            plan.stop()
        }
    }
}
