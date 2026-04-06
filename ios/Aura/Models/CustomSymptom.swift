import Foundation
import SwiftData

/// A user-defined symptom name that is stored once and offered as a selection
/// option in all future migraine/headache log entries.
@Model
final class CustomSymptom {
    var name: String
    var createdAt: Date

    init(name: String, createdAt: Date = .now) {
        self.name = name
        self.createdAt = createdAt
    }
}
