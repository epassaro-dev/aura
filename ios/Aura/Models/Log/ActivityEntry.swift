import Foundation
import SwiftData

@Model final class ActivityEntry {
    var date: Date
    var activityType: ActivityType?
    var durationMinutes: Int
    var intensity: Int  // 1–5

    init(date: Date, activityType: ActivityType? = nil, durationMinutes: Int, intensity: Int) {
        self.date = date
        self.activityType = activityType
        self.durationMinutes = durationMinutes
        self.intensity = intensity
    }
}
