import Foundation
import SwiftData

@Model final class MedicineLog {
    var date: Date
    var timestamp: Date
    var medicine: Medicine?
    var dosage: String?  // nil means use medicine.defaultDosage

    init(date: Date, timestamp: Date, medicine: Medicine? = nil, dosage: String? = nil) {
        self.date = date
        self.timestamp = timestamp
        self.medicine = medicine
        self.dosage = dosage
    }
}
