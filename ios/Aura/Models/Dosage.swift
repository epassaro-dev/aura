enum DosageUnit: String, CaseIterable, Codable {
    case mg, mcg, g, ml, IU, drops, tablet
}

struct Dosage: Codable, Hashable, Equatable {
    var amount: String
    var unit: DosageUnit

    func asString() -> String {
        return "\(amount) \(unit.rawValue)"
    }

    static func == (lhs: Dosage, rhs: Dosage) -> Bool {
        return lhs.amount == rhs.amount && lhs.unit == rhs.unit
    }
}
