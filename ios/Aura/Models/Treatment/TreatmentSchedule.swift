import Foundation
import SwiftData

@Model final class TreatmentSchedule {
    var medicine: Medicine?
    var timesPerDay: Int
    var isActive: Bool
    var startDate: Date

    init(
        medicine: Medicine? = nil,
        timesPerDay: Int = 1,
        isActive: Bool = true,
        startDate: Date = .now
    ) {
        self.medicine = medicine
        self.timesPerDay = timesPerDay
        self.isActive = isActive
        self.startDate = startDate
    }
}
