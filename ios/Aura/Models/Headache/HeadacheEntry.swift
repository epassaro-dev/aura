import Foundation
import SwiftData

enum HeadacheType: String, Codable, CaseIterable {
    case migraine
    case tensionHeadache
    case clusterHeadache
    case reboundHeadache
    case hypertensiveHeadache
    case sinusHeadache
    case hormonalHeadache
    case exerciseInduced
    case dehydrationHeadache
    case other
}

enum HeadArea: String, Codable, CaseIterable {
    case forehead
    case leftTemple
    case rightTemple
    case leftSide
    case rightSide
    case occiput
    case crown
    case aroundEyes
    case neck
    case wholeHead
}

@Model final class HeadacheEntry {
    var startTime: Date
    var endTime: Date?
    var headacheType: HeadacheType

    @Relationship(deleteRule: .nullify) var triggers: [TriggerType] = []
    @Relationship(deleteRule: .nullify) var tellingSigns: [TellingSignType] = []

    @Relationship(deleteRule: .cascade, inverse: \HeadachePainLog.headache)
    var painLogs: [HeadachePainLog] = []

    @Relationship(deleteRule: .cascade, inverse: \HeadacheSymptomLog.headache)
    var symptoms: [HeadacheSymptomLog] = []

    @Relationship(deleteRule: .cascade, inverse: \HeadacheMedicineLog.headache)
    var medications: [HeadacheMedicineLog] = []

    @Relationship(deleteRule: .cascade, inverse: \HeadacheReliefLog.headache)
    var reliefMethods: [HeadacheReliefLog] = []

    init(startTime: Date, headacheType: HeadacheType) {
        self.startTime = startTime
        self.headacheType = headacheType
    }
}
