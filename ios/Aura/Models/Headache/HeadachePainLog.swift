import Foundation
import SwiftData

@Model final class HeadachePainLog {
    var timestamp: Date
    var intensity: Int  // 1–10
    var affectedAreas: [HeadArea]

    var headache: HeadacheEntry?

    init(timestamp: Date, intensity: Int, affectedAreas: [HeadArea] = []) {
        self.timestamp = timestamp
        self.intensity = intensity
        self.affectedAreas = affectedAreas
    }
}
