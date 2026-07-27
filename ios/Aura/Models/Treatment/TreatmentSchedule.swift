import Foundation
import SwiftData

@Model final class TreatmentSchedule {
    var medicine: Medicine?
    var dosage: Dosage? // nil means use medicine.defaultDosage
    var timesPerDay: Int
    var isActive: Bool
    var startDate: Date

    init(
        medicine: Medicine? = nil,
        dosage: Dosage? = nil,
        timesPerDay: Int = 1,
        isActive: Bool = true,
        startDate: Date = .now
    ) {
        self.medicine = medicine
        self.dosage = dosage
        self.timesPerDay = timesPerDay
        self.isActive = isActive
        self.startDate = startDate
    }
}
