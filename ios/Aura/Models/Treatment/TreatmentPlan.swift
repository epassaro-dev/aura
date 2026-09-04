import Foundation
import SwiftData

@Model final class TreatmentPlan {
    var medicine: Medicine
    var dosage: Dosage? // nil means use medicine.defaultDosage
    var timesPerDay: Int
    var startDate: Date
    var endDate: Date?

    var isActive: Bool {
        endDate == nil
    }

    init(
        medicine: Medicine,
        dosage: Dosage? = nil,
        timesPerDay: Int = 1,
        startDate: Date = .now
    ) {
        self.medicine = medicine
        self.dosage = dosage
        self.timesPerDay = timesPerDay
        self.startDate = startDate
        self.endDate = nil
    }

    func stop() {
        endDate = .now
    }
}
