import Foundation
import SwiftData

@Observable final class SleepSectionViewModel {
    private let context: ModelContext
    var entries: [SleepEntry] = []
    var showAddNight = false
    var showAddNap = false

    var nightSleep: SleepEntry? {
        entries.first { $0.type == .night }
    }

    var naps: [SleepEntry] {
        entries.filter { $0.type == .nap }
    }

    init(context: ModelContext) {
        self.context = context
        fetch()
    }

    func fetch() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        let descriptor = FetchDescriptor<SleepEntry>(
            predicate: #Predicate<SleepEntry> { entry in
                entry.date >= today && entry.date < tomorrow
            }
        )
        entries = (try? context.fetch(descriptor)) ?? []
    }

    func delete(_ entry: SleepEntry) {
        context.delete(entry)
        try? context.save()
        fetch()
    }
}
