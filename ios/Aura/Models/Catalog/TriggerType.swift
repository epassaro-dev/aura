import SwiftData

@Model final class TriggerType {
    var name: String
    var sfSymbol: String
    var isDefault: Bool
    var isArchived: Bool

    @Relationship(deleteRule: .nullify, inverse: \TriggerEntry.triggerType)
    var triggerEntries: [TriggerEntry] = []

    @Relationship(inverse: \HeadacheEntry.triggers)
    var headacheEntries: [HeadacheEntry] = []

    init(name: String, sfSymbol: String, isDefault: Bool = false, isArchived: Bool = false) {
        self.name = name
        self.sfSymbol = sfSymbol
        self.isDefault = isDefault
        self.isArchived = isArchived
    }
}
