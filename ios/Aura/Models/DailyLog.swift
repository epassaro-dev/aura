import Foundation
import SwiftData

/// One entry per calendar day. Acts as the root container for all daily health data.
@Model
final class DailyLog {
    /// Normalised to midnight (start-of-day) so one object exists per day.
    var date: Date

    /// Perceived stress for the day, 0 = none, 10 = extreme.
    var stressLevel: Int?

    @Relationship(deleteRule: .cascade)
    var sleepEntries: [SleepEntry] = []

    @Relationship(deleteRule: .cascade)
    var medicationEntries: [MedicationEntry] = []

    @Relationship(deleteRule: .cascade)
    var activityEntries: [ActivityEntry] = []

    @Relationship(deleteRule: .cascade)
    var foodEntries: [FoodEntry] = []

    @Relationship(deleteRule: .cascade)
    var notes: [Note] = []

    @Relationship(deleteRule: .cascade)
    var migraineEpisodes: [MigraineEpisode] = []

    init(date: Date = Calendar.current.startOfDay(for: .now)) {
        self.date = date
    }
}
