import Foundation
import SwiftData
import Combine

/// Manages read/write access to the current day's `DailyLog`.
/// Designed to be injected from `AuraApp` so the `ModelContext` is always available.
@MainActor
final class DailyLogViewModel: ObservableObject {
    @Published var currentLog: DailyLog?
    @Published var errorMessage: String?

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchOrCreateTodaysLog()
    }

    // MARK: - Fetch / Create

    func fetchOrCreateTodaysLog() {
        let today      = Calendar.current.startOfDay(for: .now)
        let descriptor = FetchDescriptor<DailyLog>(
            predicate: #Predicate { $0.date == today }
        )

        do {
            let results = try modelContext.fetch(descriptor)
            if let existing = results.first {
                currentLog = existing
            } else {
                let newLog = DailyLog(date: today)
                modelContext.insert(newLog)
                try modelContext.save()
                currentLog = newLog
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Stress

    func setStressLevel(_ level: Int) {
        currentLog?.stressLevel = level
        save()
    }

    // MARK: - Add entries

    func addSleepEntry(_ entry: SleepEntry) {
        guard let log = currentLog else { return }
        entry.dailyLog = log
        log.sleepEntries.append(entry)
        save()
    }

    func addMedicationEntry(_ entry: MedicationEntry) {
        guard let log = currentLog else { return }
        entry.dailyLog = log
        log.medicationEntries.append(entry)
        save()
    }

    func addActivityEntry(_ entry: ActivityEntry) {
        guard let log = currentLog else { return }
        entry.dailyLog = log
        log.activityEntries.append(entry)
        save()
    }

    func addFoodEntry(_ entry: FoodEntry) {
        guard let log = currentLog else { return }
        entry.dailyLog = log
        log.foodEntries.append(entry)
        save()
    }

    func addNote(_ note: Note) {
        guard let log = currentLog else { return }
        note.dailyLog = log
        log.notes.append(note)
        save()
    }

    func addMigraineEpisode(_ episode: MigraineEpisode) {
        guard let log = currentLog else { return }
        episode.dailyLog = log
        log.migraineEpisodes.append(episode)
        save()
    }

    // MARK: - Delete entries

    func deleteSleepEntry(_ entry: SleepEntry) {
        currentLog?.sleepEntries.removeAll { $0.persistentModelID == entry.persistentModelID }
        modelContext.delete(entry)
        save()
    }

    func deleteMedicationEntry(_ entry: MedicationEntry) {
        currentLog?.medicationEntries.removeAll { $0.persistentModelID == entry.persistentModelID }
        modelContext.delete(entry)
        save()
    }

    func deleteActivityEntry(_ entry: ActivityEntry) {
        currentLog?.activityEntries.removeAll { $0.persistentModelID == entry.persistentModelID }
        modelContext.delete(entry)
        save()
    }

    func deleteFoodEntry(_ entry: FoodEntry) {
        currentLog?.foodEntries.removeAll { $0.persistentModelID == entry.persistentModelID }
        modelContext.delete(entry)
        save()
    }

    func deleteNote(_ note: Note) {
        currentLog?.notes.removeAll { $0.persistentModelID == note.persistentModelID }
        modelContext.delete(note)
        save()
    }

    func deleteMigraineEpisode(_ episode: MigraineEpisode) {
        currentLog?.migraineEpisodes.removeAll { $0.persistentModelID == episode.persistentModelID }
        modelContext.delete(episode)
        save()
    }

    // MARK: - Persist

    private func save() {
        do {
            try modelContext.save()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
