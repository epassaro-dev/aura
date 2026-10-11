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

    func scheduleString() -> String {
        switch timesPerDay {
        case 1: String(localized: "Once per day")
        case 2: String(localized: "Twice per day")
        default: String(localized: "\(timesPerDay) times per day")
        }
    }

    func dosageString() -> String {
        dosage?.asString() ?? medicine.defaultDosage?.asString() ?? ""
    }
}
