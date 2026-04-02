import Foundation
import SwiftData

enum HeadacheSide: String, Codable, CaseIterable {
    case left        = "Left"
    case right       = "Right"
    case bilateral   = "Both Sides"
    case unspecified = "Unspecified"
}

enum HeadacheType: String, Codable, CaseIterable {
    case migraine        = "Migraine"
    case tensionHeadache = "Tension Headache"
    case cluster         = "Cluster Headache"
    case other           = "Other"
}

/// Common migraine symptoms; stored as raw String values in MigraineEpisode.
enum MigraineSymptom: String, Codable, CaseIterable {
    case aura             = "Aura"
    case nausea           = "Nausea"
    case vomiting         = "Vomiting"
    case lightSensitivity = "Light Sensitivity"
    case soundSensitivity = "Sound Sensitivity"
    case smellSensitivity = "Smell Sensitivity"
    case dizziness        = "Dizziness"
    case fatigue          = "Fatigue"
    case neckStiffness    = "Neck Stiffness"
}

@Model
final class MigraineEpisode {
    var startTime: Date
    var endTime:   Date?
    /// Pain intensity 1 (mild) – 10 (unbearable).
    var intensity: Int
    var type:      HeadacheType
    var side:      HeadacheSide
    /// Raw values of MigraineSymptom.
    var symptoms:  [String]
    /// Free-text trigger descriptions.
    var triggers:  [String]
    var notes:     String

    var dailyLog: DailyLog?

    var duration: TimeInterval? {
        guard let end = endTime else { return nil }
        return end.timeIntervalSince(startTime)
    }

    var durationFormatted: String? {
        guard let d = duration else { return nil }
        let total   = Int(d)
        let hours   = total / 3600
        let minutes = (total % 3600) / 60
        if hours > 0 { return "\(hours)h \(minutes)m" }
        return "\(minutes)m"
    }

    init(
        startTime: Date        = .now,
        intensity: Int         = 5,
        type:      HeadacheType  = .migraine,
        side:      HeadacheSide  = .unspecified,
        symptoms:  [String]    = [],
        triggers:  [String]    = [],
        notes:     String      = ""
    ) {
        self.startTime = startTime
        self.intensity = intensity
        self.type      = type
        self.side      = side
        self.symptoms  = symptoms
        self.triggers  = triggers
        self.notes     = notes
    }
}
