import SwiftData

/// Shared shape of all user-extensible catalog types. Lets catalog management
/// UI and logic be written once instead of per concrete model.
protocol CatalogItem: PersistentModel {
    var name: String { get set }
    var sfSymbol: String { get set }
    var isDefault: Bool { get set }
    var isArchived: Bool { get set }
}

extension FeelingType: CatalogItem {}
extension TriggerType: CatalogItem {}
extension SymptomType: CatalogItem {}
extension Medicine: CatalogItem {}
extension FoodItem: CatalogItem {}
extension ActivityType: CatalogItem {}
extension TellingSignType: CatalogItem {}
extension ReliefMethodType: CatalogItem {}
