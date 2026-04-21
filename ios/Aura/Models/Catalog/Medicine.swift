import SwiftData

@Model final class Medicine {
    var name: String
    var sfSymbol: String
    var isDefault: Bool
    var isArchived: Bool
    var defaultDosage: String?

    @Relationship(deleteRule: .nullify, inverse: \MedicineLog.medicine)
    var medicineLogs: [MedicineLog] = []

    @Relationship(deleteRule: .nullify, inverse: \HeadacheMedicineLog.medicine)
    var headacheMedicineLogs: [HeadacheMedicineLog] = []

    init(name: String, sfSymbol: String, isDefault: Bool = false, isArchived: Bool = false, defaultDosage: String? = nil) {
        self.name = name
        self.sfSymbol = sfSymbol
        self.isDefault = isDefault
        self.isArchived = isArchived
        self.defaultDosage = defaultDosage
    }
}
