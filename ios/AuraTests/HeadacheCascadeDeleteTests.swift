import XCTest
import SwiftData
@testable import Aura

final class HeadacheCascadeDeleteTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!

    override func setUpWithError() throws {
        container = try makeContainer()
        context = ModelContext(container)
        context.autosaveEnabled = false
    }

    func testDeletingHeadacheDeletesPainLogs() throws {
        let headache = HeadacheEntry(startTime: .now, headacheType: .migraine)
        let painLog = HeadachePainLog(timestamp: .now, intensity: 7, affectedAreas: [.forehead])
        context.insert(headache)
        context.insert(painLog)
        headache.painLogs.append(painLog)
        try context.save()

        context.delete(headache)
        try context.save()

        let painLogs = try context.fetch(FetchDescriptor<HeadachePainLog>())
        XCTAssertTrue(painLogs.isEmpty)
    }

    func testDeletingHeadacheDeletesSymptomLogs() throws {
        let headache = HeadacheEntry(startTime: .now, headacheType: .migraine)
        let symptomLog = HeadacheSymptomLog(timestamp: .now)
        context.insert(headache)
        context.insert(symptomLog)
        headache.symptoms.append(symptomLog)
        try context.save()

        context.delete(headache)
        try context.save()

        let symptomLogs = try context.fetch(FetchDescriptor<HeadacheSymptomLog>())
        XCTAssertTrue(symptomLogs.isEmpty)
    }

    func testDeletingHeadacheDeletesMedicineLogs() throws {
        let headache = HeadacheEntry(startTime: .now, headacheType: .migraine)
        let medicineLog = HeadacheMedicineLog(timestamp: .now)
        context.insert(headache)
        context.insert(medicineLog)
        headache.medications.append(medicineLog)
        try context.save()

        context.delete(headache)
        try context.save()

        let medicineLogs = try context.fetch(FetchDescriptor<HeadacheMedicineLog>())
        XCTAssertTrue(medicineLogs.isEmpty)
    }

    func testDeletingHeadacheDeletesReliefLogs() throws {
        let headache = HeadacheEntry(startTime: .now, headacheType: .migraine)
        let reliefLog = HeadacheReliefLog(timestamp: .now)
        context.insert(headache)
        context.insert(reliefLog)
        headache.reliefMethods.append(reliefLog)
        try context.save()

        context.delete(headache)
        try context.save()

        let reliefLogs = try context.fetch(FetchDescriptor<HeadacheReliefLog>())
        XCTAssertTrue(reliefLogs.isEmpty)
    }
}
