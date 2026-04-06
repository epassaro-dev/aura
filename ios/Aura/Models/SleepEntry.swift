import Foundation
import SwiftData

enum SleepType: String, Codable, CaseIterable {
    case night = "Night Sleep"
    case nap = "Nap"
}

enum SleepQuality: Int, Codable, CaseIterable {
    case poor = 1
    case fair = 2
    case average = 3
    case good = 4
    case excellent = 5

    var label: String {
        switch self {
        case .poor: return "Poor"
        case .fair: return "Fair"
        case .average: return "Average"
        case .good: return "Good"
        case .excellent: return "Excellent"
        }
    }

    var systemImage: String {
        switch self {
        case .poor: return "moon.zzz"
        case .fair: return "moon"
        case .average: return "moon.fill"
        case .good: return "moon.stars"
        case .excellent: return "moon.stars.fill"
        }
    }
}

@Model
final class SleepEntry {
    var startTime: Date
    var endTime: Date
    var quality: SleepQuality
    var type: SleepType
    var notes: String

    var dailyLog: DailyLog?

    var duration: TimeInterval {
        max(0, endTime.timeIntervalSince(startTime))
    }

    var durationFormatted: String {
        let total = Int(duration)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        if hours > 0 { return "\(hours)h \(minutes)m" }
        return "\(minutes)m"
    }

    init(
        startTime: Date = Calendar.current.date(byAdding: .hour, value: -8, to: .now) ?? .now,
        endTime: Date = .now,
        quality: SleepQuality = .average,
        type: SleepType = .night,
        notes: String = ""
    ) {
        self.startTime = startTime
        self.endTime = endTime
        self.quality = quality
        self.type = type
        self.notes = notes
    }
}

