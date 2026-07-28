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

    func testSeedingCreatesFiveMedicines() throws {
        DataSeeder.seed(context: context)
        let medicines = try context.fetch(FetchDescriptor<Medicine>())
        XCTAssertEqual(medicines.count, 5)
    }

    func testSeedingDoesNotRunIfMedicinesAlreadyExist() throws {
        context.insert(Medicine(name: "someMedicineName", sfSymbol: "some.symbol"))
        try context.save()
        let medicines = try context.fetch(FetchDescriptor<Medicine>())
        XCTAssertEqual(medicines.count, 1, "Seeding should not run if context already contains medicines.")
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
