import Foundation
import SwiftData

/// The phase of a migraine in which warning or recovery symptoms appear.
enum EpisodePhase: String, Codable, CaseIterable {
    case prodrome = "Prodrome (warning)"
    case postdrome = "Postdrome (recovery)"

    var systemImage: String {
        switch self {
        case .prodrome: return "exclamationmark.triangle.fill"
        case .postdrome: return "arrow.uturn.backward.circle.fill"
        }
    }

    var description: String {
        switch self {
        case .prodrome:
            return "Symptoms appearing in the hours or days before a migraine."
        case .postdrome:
            return "Symptoms appearing in the hours or days after a migraine."
        }
    }
}

/// Records headache-related symptoms that occur outside of an active episode —
/// either as warning signs (prodrome) in the days leading up to a migraine,
/// or as recovery symptoms (postdrome) in the days following one.
@Model
final class HeadacheSymptomEntry {
    var phase: EpisodePhase
    /// Raw values of built-in or custom symptom names.
    var symptoms: [String]
    var notes: String
    var loggedAt: Date

    var dailyLog: DailyLog?

    init(
        phase: EpisodePhase = .prodrome,
        symptoms: [String] = [],
        notes: String = "",
        loggedAt: Date = .now
    ) {
        self.phase = phase
        self.symptoms = symptoms
        self.notes = notes
        self.loggedAt = loggedAt
    }
}
