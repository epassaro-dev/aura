import Foundation
import SwiftData

@Model
final class Note {
    var content:   String
    var createdAt: Date

    var dailyLog: DailyLog?

    init(content: String = "", createdAt: Date = .now) {
        self.content   = content
        self.createdAt = createdAt
    }
}
