import XCTest
import SwiftData
@testable import Aura

final class CatalogNullifyTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!

    override func setUpWithError() throws {
        container = try makeContainer()
        context = ModelContext(container)
        context.autosaveEnabled = false
    }

    func testDeletingFeelingTypeNullifiesFeelingEntry() throws {
        let feelingType = FeelingType(name: "Anxious", sfSymbol: "brain.head.profile")
        let entry = FeelingEntry(date: .now, feelingType: feelingType, intensity: 3)
        context.insert(feelingType)
        context.insert(entry)
        try context.save()

        context.delete(feelingType)
        try context.save()

        let entries = try context.fetch(FetchDescriptor<FeelingEntry>())
        XCTAssertEqual(entries.count, 1, "FeelingEntry should survive deletion of its type")
        XCTAssertNil(entries.first?.feelingType)
    }

    func testDeletingSymptomTypeNullifiesSymptomEntry() throws {
        let symptomType = SymptomType(name: "Nausea", sfSymbol: "waveform.path.ecg")
        let entry = SymptomEntry(date: .now, symptomType: symptomType)
        context.insert(symptomType)
        context.insert(entry)
        try context.save()

        context.delete(symptomType)
        try context.save()

        let entries = try context.fetch(FetchDescriptor<SymptomEntry>())
        XCTAssertEqual(entries.count, 1, "SymptomEntry should survive deletion of its type")
        XCTAssertNil(entries.first?.symptomType)
    }

    func testDeletingTriggerTypeNullifiesTriggerEntry() throws {
        let triggerType = TriggerType(name: "Stress", sfSymbol: "bolt.fill")
        let entry = TriggerEntry(date: .now, triggerType: triggerType)
        context.insert(triggerType)
        context.insert(entry)
        try context.save()

        context.delete(triggerType)
        try context.save()

        let entries = try context.fetch(FetchDescriptor<TriggerEntry>())
        XCTAssertEqual(entries.count, 1, "TriggerEntry should survive deletion of its type")
        XCTAssertNil(entries.first?.triggerType)
    }

    func testDeletingMedicineNullifiesMedicineLog() throws {
        let medicine = Medicine(name: "Ibuprofen", sfSymbol: "pills.fill", defaultDosage: "400mg")
        let log = MedicineLog(date: .now, timestamp: .now, medicine: medicine)
        context.insert(medicine)
        context.insert(log)
        try context.save()

        context.delete(medicine)
        try context.save()

        let logs = try context.fetch(FetchDescriptor<MedicineLog>())
        XCTAssertEqual(logs.count, 1, "MedicineLog should survive deletion of its medicine")
        XCTAssertNil(logs.first?.medicine)
    }
}
