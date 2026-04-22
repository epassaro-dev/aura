import XCTest
import SwiftData
@testable import Aura

final class MedicineCatalogViewModelTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!

    override func setUpWithError() throws {
        container = try makeContainer()
        context = ModelContext(container)
        context.autosaveEnabled = false
    }

    func testAddCustomMedicineAppearsInList() throws {
        let vm = MedicineCatalogViewModel(context: context)
        XCTAssertTrue(vm.medicines.isEmpty)

        vm.addCustomMedicine(name: "Metoprolol", defaultDosage: "50mg")
        XCTAssertEqual(vm.medicines.count, 1)
        XCTAssertEqual(vm.medicines.first?.name, "Metoprolol")
        XCTAssertEqual(vm.medicines.first?.sfSymbol, "pills.fill")
        XCTAssertEqual(vm.medicines.first?.defaultDosage, "50mg")
    }

    func testArchivedMedicineNotShownInList() throws {
        let archived = Medicine(name: "OldMed", sfSymbol: "pills.fill", isArchived: true)
        let active = Medicine(name: "ActiveMed", sfSymbol: "pills.fill")
        context.insert(archived)
        context.insert(active)
        try context.save()

        let vm = MedicineCatalogViewModel(context: context)
        XCTAssertEqual(vm.medicines.count, 1)
        XCTAssertEqual(vm.medicines.first?.name, "ActiveMed")
    }

    func testAddCustomMedicineWithBlankNameIsIgnored() throws {
        let vm = MedicineCatalogViewModel(context: context)
        vm.addCustomMedicine(name: "   ", defaultDosage: nil)
        XCTAssertTrue(vm.medicines.isEmpty)
    }

    func testAddCustomMedicineStripsWhitespaceFromDosage() throws {
        let vm = MedicineCatalogViewModel(context: context)
        vm.addCustomMedicine(name: "Aspirin", defaultDosage: "  ")
        XCTAssertNil(vm.medicines.first?.defaultDosage)
    }
}
