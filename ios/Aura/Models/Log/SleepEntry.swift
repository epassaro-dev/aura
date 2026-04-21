import SwiftData
import Foundation

enum SleepType: String, Codable {
    case night
    case nap
}

@Model final class SleepEntry {
    var date: Date
    var type: SleepType
    var startTime: Date
    var endTime: Date
    var quality: Int  // 1–5

    init(date: Date, type: SleepType, startTime: Date, endTime: Date, quality: Int) {
        self.date = date
        self.type = type
        self.startTime = startTime
        self.endTime = endTime
        self.quality = quality
    }
}
