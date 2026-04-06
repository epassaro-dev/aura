import SwiftUI
import SwiftData

// MARK: - Shared preview container

extension ModelContainer {
    /// An in-memory container used exclusively for Xcode previews.
    @MainActor
    static var preview: ModelContainer {
        let schema = Schema([
            DailyLog.self,
            SleepEntry.self,
            MedicationEntry.self,
            ActivityEntry.self,
            FoodEntry.self,
            Note.self,
            MigraineEpisode.self,
            HeadacheEpisode.self,
            HeadacheSymptomEntry.self,
            CustomSymptom.self,
        ])
        let container = try! ModelContainer(
            for: schema,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        return container
    }
}

// MARK: - ViewModel preview factories

extension DailyLogViewModel {
    /// A pre-populated view model backed by an in-memory store for use in Xcode previews.
    @MainActor
    static var preview: DailyLogViewModel {
        let container = ModelContainer.preview
        let vm = DailyLogViewModel(modelContext: container.mainContext)

        // Seed sample data so cards appear populated in preview.
        if let log = vm.currentLog {
            log.stressLevel = 4

            let sleep = SleepEntry(
                startTime: Calendar.current.date(byAdding: .hour, value: -8, to: .now)!,
                endTime: .now,
                quality: .good,
                type: .night
            )
            sleep.dailyLog = log
            log.sleepEntries.append(sleep)

            let med = MedicationEntry(name: "Topiramate", dosage: "25 mg", isPreventive: true)
            med.dailyLog = log
            log.medicationEntries.append(med)

            let activity = ActivityEntry(type: .walking, intensity: .light, durationMinutes: 20)
            activity.dailyLog = log
            log.activityEntries.append(activity)

            let food = FoodEntry(mealType: .breakfast, items: ["Oats", "Banana"])
            food.dailyLog = log
            log.foodEntries.append(food)

            let note = Note(content: "Slept well, felt rested.")
            note.dailyLog = log
            log.notes.append(note)

            let migraine = MigraineEpisode(
                intensity: 7,
                area: .right,
                symptoms: [MigraineSymptom.nausea.rawValue, MigraineSymptom.lightSensitivity.rawValue]
            )
            migraine.dailyLog = log
            log.migraineEpisodes.append(migraine)
        }

        return vm
    }
}
