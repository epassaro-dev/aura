import SwiftData

@Model final class SymptomType {
    var name: String
    var sfSymbol: String
    var isDefault: Bool
    var isArchived: Bool

    @Relationship(deleteRule: .nullify, inverse: \SymptomEntry.symptomType)
    var symptomEntries: [SymptomEntry] = []

    @Relationship(deleteRule: .nullify, inverse: \HeadacheSymptomLog.symptomType)
    var headacheSymptomLogs: [HeadacheSymptomLog] = []

    init(name: String, sfSymbol: String, isDefault: Bool = false, isArchived: Bool = false) {
        self.name = name
        self.sfSymbol = sfSymbol
        self.isDefault = isDefault
        self.isArchived = isArchived
    }
}
