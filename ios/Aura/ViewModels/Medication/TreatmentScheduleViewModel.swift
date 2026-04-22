import Foundation
import SwiftData

@Observable final class TreatmentScheduleViewModel {
    private let context: ModelContext
    let medicine: Medicine
    var timesPerDay: Int = 1

    init(context: ModelContext, medicine: Medicine) {
        self.context = context
        self.medicine = medicine
    }

    func save() {
        for schedule in medicine.schedules where schedule.isActive {
            schedule.isActive = false
        }
        let schedule = TreatmentSchedule(medicine: medicine, timesPerDay: timesPerDay)
        context.insert(schedule)
        try? context.save()
    }
}
