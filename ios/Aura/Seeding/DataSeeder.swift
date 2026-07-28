import Foundation
import OSLog
import SwiftData

enum DataSeeder {
    static func seed(context: ModelContext) {
        seedMedicines(context: context)
    }

    private static func seedMedicines(context: ModelContext) {
        let defaults: [(name: String, dosage: Dosage)] = [
            ("Propranolol", Dosage(amount: "40", unit: .mg)),
            ("Topiramate", Dosage(amount: "25", unit: .mg)),
            ("Amitriptyline", Dosage(amount: "10", unit: .mg)),
            ("Valproate", Dosage(amount: "500", unit: .mg)),
            ("Magnesium", Dosage(amount: "400", unit: .mg)),
        ]

        do {
            if try context.fetch(FetchDescriptor<Medicine>()).count > 0 { return }
        } catch {
            Logger.seeding.error("Failed to check if medicines are seeded: \(String(describing: error), privacy: .public)")
            return
        }

        for entry in defaults {
            context.insert(Medicine(
                name: entry.name,
                sfSymbol: "pills.fill",
                defaultDosage: entry.dosage
            ))
        }

        do {
            try context.save()
        } catch {
            Logger.seeding.error("Failed to save seeded medicines: \(String(describing: error), privacy: .public)")
        }
    }
}
