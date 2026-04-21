import Foundation
import SwiftData

@Model final class HeadacheSymptomLog {
    var timestamp: Date
    var symptomType: SymptomType?
    var headache: HeadacheEntry?

    init(timestamp: Date, symptomType: SymptomType? = nil) {
        self.timestamp = timestamp
        self.symptomType = symptomType
    }
}
