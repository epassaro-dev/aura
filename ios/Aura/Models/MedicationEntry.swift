import Foundation
import SwiftData

@Model
final class MedicationEntry {
    var name:        String
    var dosage:      String
    var takenAt:     Date
    var isPreventive: Bool
    var notes:       String

    var dailyLog: DailyLog?

    init(
        name:         String = "",
        dosage:       String = "",
        takenAt:      Date   = .now,
        isPreventive: Bool   = false,
        notes:        String = ""
    ) {
        self.name         = name
        self.dosage       = dosage
        self.takenAt      = takenAt
        self.isPreventive = isPreventive
        self.notes        = notes
    }
}
