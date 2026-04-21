import Foundation
import SwiftData

@Model final class FeelingEntry {
    var date: Date
    var feelingType: FeelingType?
    var intensity: Int  // 1–5

    init(date: Date, feelingType: FeelingType? = nil, intensity: Int) {
        self.date = date
        self.feelingType = feelingType
        self.intensity = intensity
    }
}
