import Foundation
import SwiftData

@Model final class HeadacheReliefLog {
    var timestamp: Date
    var reliefMethodType: ReliefMethodType?
    var efficacy: Int?  // 1–5, recorded after the fact

    var headache: HeadacheEntry?

    init(timestamp: Date, reliefMethodType: ReliefMethodType? = nil) {
        self.timestamp = timestamp
        self.reliefMethodType = reliefMethodType
    }
}
