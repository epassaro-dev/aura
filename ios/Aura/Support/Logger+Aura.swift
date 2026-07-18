import Foundation
import OSLog

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "Aura"

    static let persistence = Logger(subsystem: subsystem, category: "persistence")
    static let seeding = Logger(subsystem: subsystem, category: "seeding")
}
