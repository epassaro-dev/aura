import SwiftData

@Model final class ActivityType {
    var name: String
    var sfSymbol: String
    var isDefault: Bool
    var isArchived: Bool

    @Relationship(deleteRule: .nullify, inverse: \ActivityEntry.activityType)
    var entries: [ActivityEntry] = []

    init(name: String, sfSymbol: String, isDefault: Bool = false, isArchived: Bool = false) {
        self.name = name
        self.sfSymbol = sfSymbol
        self.isDefault = isDefault
        self.isArchived = isArchived
    }
}
