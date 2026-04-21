import SwiftData

@Model final class TellingSignType {
    var name: String
    var sfSymbol: String
    var isDefault: Bool
    var isArchived: Bool

    @Relationship(inverse: \HeadacheEntry.tellingSigns)
    var headacheEntries: [HeadacheEntry] = []

    init(name: String, sfSymbol: String, isDefault: Bool = false, isArchived: Bool = false) {
        self.name = name
        self.sfSymbol = sfSymbol
        self.isDefault = isDefault
        self.isArchived = isArchived
    }
}
