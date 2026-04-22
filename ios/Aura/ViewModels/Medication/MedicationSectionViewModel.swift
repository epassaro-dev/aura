import Foundation
import SwiftData

@Observable final class MedicationSectionViewModel {
    private let context: ModelContext
    var schedules: [TreatmentSchedule] = []
    var todayLogs: [MedicineLog] = []
    var showCatalog = false

    init(context: ModelContext) {
        self.context = context
        fetch()
    }

    func fetch() {
        let scheduleDescriptor = FetchDescriptor<TreatmentSchedule>(
            predicate: #Predicate<TreatmentSchedule> { schedule in
                schedule.isActive == true
            }
        )
        schedules = (try? context.fetch(scheduleDescriptor)) ?? []

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        let logDescriptor = FetchDescriptor<MedicineLog>(
            predicate: #Predicate<MedicineLog> { log in
                log.date >= today && log.date < tomorrow
            }
        )
        todayLogs = (try? context.fetch(logDescriptor)) ?? []
    }

    func takenCount(for schedule: TreatmentSchedule) -> Int {
        guard let medicine = schedule.medicine else { return 0 }
        let medicineID = medicine.persistentModelID
        return todayLogs.filter { $0.medicine?.persistentModelID == medicineID }.count
    }

    func isCompleted(for schedule: TreatmentSchedule) -> Bool {
        takenCount(for: schedule) >= schedule.timesPerDay
    }

    func markTaken(for schedule: TreatmentSchedule) {
        guard let medicine = schedule.medicine, !isCompleted(for: schedule) else { return }
        let today = Calendar.current.startOfDay(for: .now)
        let log = MedicineLog(date: today, timestamp: .now, medicine: medicine, dosage: medicine.defaultDosage)
        context.insert(log)
        try? context.save()
        fetch()
    }
}
