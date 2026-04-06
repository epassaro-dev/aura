import Foundation
import SwiftData

/// Types of non-migraine headache episodes.
/// Migraine is tracked separately via `MigraineEpisode`.
enum HeadacheType: String, Codable, CaseIterable {
    case tensionHeadache = "Tension Headache"
    case cluster = "Cluster Headache"
    case other = "Other"
}

/// A non-migraine headache episode (tension, cluster, etc.).
/// Migraine episodes are tracked via the separate `MigraineEpisode` model.
@Model
final class HeadacheEpisode {
    var type: HeadacheType
    var area: HeadacheArea
    /// Pain intensity 1 (mild) – 10 (unbearable).
    var intensity: Int
    var startTime: Date
    var endTime: Date?
    /// Raw values of built-in or custom symptom names.
    var symptoms: [String]
    /// Free-text trigger descriptions.
    var triggers: [String]
    var notes: String

    var dailyLog: DailyLog?

    var duration: TimeInterval? {
        guard let end = endTime else { return nil }
        return end.timeIntervalSince(startTime)
    }

    var durationFormatted: String? {
        guard let d = duration else { return nil }
        let total = Int(d)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        if hours > 0 { return "\(hours)h \(minutes)m" }
        return "\(minutes)m"
    }

    init(
        type: HeadacheType = .tensionHeadache,
        area: HeadacheArea = .unspecified,
        intensity: Int = 5,
        startTime: Date = .now,
        symptoms: [String] = [],
        triggers: [String] = [],
        notes: String = ""
    ) {
        self.type = type
        self.area = area
        self.intensity = intensity
        self.startTime = startTime
        self.symptoms = symptoms
        self.triggers = triggers
        self.notes = notes
    }
}
