import Foundation
import SwiftData

@Model final class TriggerEntry {
    var date: Date
    var triggerType: TriggerType?

    init(date: Date, triggerType: TriggerType? = nil) {
        self.date = date
        self.triggerType = triggerType
    }
}
