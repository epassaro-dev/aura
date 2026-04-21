import Foundation
import SwiftData

@Model final class SymptomEntry {
    var date: Date
    var symptomType: SymptomType?

    init(date: Date, symptomType: SymptomType? = nil) {
        self.date = date
        self.symptomType = symptomType
    }
}
