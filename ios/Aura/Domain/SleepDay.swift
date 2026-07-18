import Foundation

/// Derived, display-ready view of one day's sleep entries.
struct SleepDay {
    let entries: [SleepEntry]

    var nightSleep: SleepEntry? {
        entries.first { $0.type == .night }
    }

    var naps: [SleepEntry] {
        entries.filter { $0.type == .nap }
    }

    /// The day a sleep entry belongs to. Sleep that crosses midnight counts
    /// toward the day the user woke up on.
    static func dayAnchor(forSleepEnding end: Date, calendar: Calendar = .current) -> Date {
        calendar.startOfDay(for: end)
    }

    static func durationText(from interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}
