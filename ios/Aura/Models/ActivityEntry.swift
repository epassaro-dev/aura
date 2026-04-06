import Foundation
import SwiftData

enum ActivityType: String, Codable, CaseIterable {
    case walking = "Walking"
    case running = "Running"
    case cycling = "Cycling"
    case swimming = "Swimming"
    case yoga = "Yoga"
    case gym = "Gym"
    case other = "Other"

    var systemImage: String {
        switch self {
        case .walking: return "figure.walk"
        case .running: return "figure.run"
        case .cycling: return "figure.outdoor.cycle"
        case .swimming: return "figure.pool.swim"
        case .yoga: return "figure.yoga"
        case .gym: return "figure.strengthtraining.traditional"
        case .other: return "figure.mixed.cardio"
        }
    }
}

enum ActivityIntensity: String, Codable, CaseIterable {
    case light = "Light"
    case moderate = "Moderate"
    case vigorous = "Vigorous"
}

@Model
final class ActivityEntry {
    var type: ActivityType
    var intensity: ActivityIntensity
    var durationMinutes: Int
    var notes: String
    var loggedAt: Date

    var dailyLog: DailyLog?

    init(
        type: ActivityType = .walking,
        intensity: ActivityIntensity = .moderate,
        durationMinutes: Int = 30,
        notes: String = "",
        loggedAt: Date = .now
    ) {
        self.type = type
        self.intensity = intensity
        self.durationMinutes = durationMinutes
        self.notes = notes
        self.loggedAt = loggedAt
    }
}

