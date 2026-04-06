import Foundation
import SwiftData

/// The location of head pain. Covers all common pain areas including top and back.
enum HeadacheArea: String, Codable, CaseIterable {
    case left = "Left"
    case right = "Right"
    case bilateral = "Both Sides"
    case top = "Top"
    case back = "Back / Occipital"
    case unspecified = "Unspecified"
}

/// Built-in migraine symptoms. Users can additionally define custom symptoms via `CustomSymptom`.
enum MigraineSymptom: String, Codable, CaseIterable {
    case aura = "Aura"
    case nausea = "Nausea"
    case vomiting = "Vomiting"
    case lightSensitivity = "Light Sensitivity"
    case soundSensitivity = "Sound Sensitivity"
    case smellSensitivity = "Smell Sensitivity"
    case dizziness = "Dizziness"
    case fatigue = "Fatigue"
    case neckStiffness = "Neck Stiffness"
}

/// A migraine episode — a specific, medically-defined event with a clear start (and optional end).
/// Non-migraine headaches are tracked separately via `HeadacheEpisode`.
/// Warning (prodrome) and recovery (postdrome) symptoms that appear on other days
/// are logged via `HeadacheSymptomEntry` on their respective `DailyLog`.
@Model
final class MigraineEpisode {
    var startTime: Date
    var endTime: Date?
    /// Pain intensity 1 (mild) – 10 (unbearable).
    var intensity: Int
    var area: HeadacheArea
    /// Raw values of `MigraineSymptom` or `CustomSymptom.name`.
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
        startTime: Date = .now,
        intensity: Int = 5,
        area: HeadacheArea = .unspecified,
        symptoms: [String] = [],
        triggers: [String] = [],
        notes: String = ""
    ) {
        self.startTime = startTime
        self.intensity = intensity
        self.area = area
        self.symptoms = symptoms
        self.triggers = triggers
        self.notes = notes
    }
}
