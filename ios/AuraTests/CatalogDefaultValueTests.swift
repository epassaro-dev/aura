import XCTest
@testable import Aura

final class CatalogDefaultValueTests: XCTestCase {
    func testCatalogItemDefaultValues() {
        let feeling = FeelingType(name: "Happy", sfSymbol: "face.smiling")
        XCTAssertFalse(feeling.isDefault)
        XCTAssertFalse(feeling.isArchived)
    }

    func testMedicineDefaultValues() {
        let medicine = Medicine(name: "Aspirin", sfSymbol: "pills")
        XCTAssertFalse(medicine.isDefault)
        XCTAssertFalse(medicine.isArchived)
        XCTAssertNil(medicine.defaultDosage)
    }

    func testHeadacheEntryDefaultValues() {
        let headache = HeadacheEntry(startTime: .now, headacheType: .migraine)
        XCTAssertNil(headache.endTime)
        XCTAssertTrue(headache.painLogs.isEmpty)
        XCTAssertTrue(headache.symptoms.isEmpty)
        XCTAssertTrue(headache.medications.isEmpty)
        XCTAssertTrue(headache.reliefMethods.isEmpty)
        XCTAssertTrue(headache.triggers.isEmpty)
        XCTAssertTrue(headache.tellingSigns.isEmpty)
    }
}
