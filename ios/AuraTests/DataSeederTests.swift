import XCTest
import SwiftData
@testable import Aura

final class DataSeederTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!

    override func setUpWithError() throws {
        container = try makeContainer()
        context = ModelContext(container)
        context.autosaveEnabled = false
    }

    func testSeedingCreatesFiveDefaultMedicines() throws {
        DataSeeder.seed(context: context)
        let medicines = try context.fetch(FetchDescriptor<Medicine>())
        XCTAssertEqual(medicines.count, 5)
        XCTAssertTrue(medicines.allSatisfy { $0.isDefault })
    }

    func testSeedingIsIdempotent() throws {
        DataSeeder.seed(context: context)
        DataSeeder.seed(context: context)
        let medicines = try context.fetch(FetchDescriptor<Medicine>())
        XCTAssertEqual(medicines.count, 5, "Re-seeding should not create duplicates")
    }

    func testDefaultMedicineNames() throws {
        DataSeeder.seed(context: context)
        let medicines = try context.fetch(FetchDescriptor<Medicine>())
        let names = Set(medicines.map { $0.name })
        XCTAssertTrue(names.contains("Propranolol"))
        XCTAssertTrue(names.contains("Topiramate"))
        XCTAssertTrue(names.contains("Amitriptyline"))
        XCTAssertTrue(names.contains("Valproate"))
        XCTAssertTrue(names.contains("Magnesium"))
    }
}
