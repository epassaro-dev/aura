import Foundation
import SwiftData

@Model final class HeadacheMedicineLog {
    var timestamp: Date
    var medicine: Medicine?
    var dosage: String?  // nil means use medicine.defaultDosage
    var efficacy: Int?   // 1–5, recorded after the fact

    var headache: HeadacheEntry?

    init(timestamp: Date, medicine: Medicine? = nil, dosage: String? = nil) {
        self.timestamp = timestamp
        self.medicine = medicine
        self.dosage = dosage
    }
}
