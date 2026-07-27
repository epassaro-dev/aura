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

        for entry in defaults {
            let entryName = entry.name
            let descriptor = FetchDescriptor<Medicine>(
                predicate: #Predicate<Medicine> { medicine in
                    medicine.name == entryName && medicine.isDefault == true
                }
            )
            do {
                guard try context.fetch(descriptor).isEmpty else { continue }
            } catch {
                let details = String(describing: error)
                Logger.seeding.error("Failed to look up default medicine \(entryName, privacy: .public): \(details, privacy: .public)")
                continue
            }
            context.insert(Medicine(
                name: entry.name,
                sfSymbol: "pills.fill",
                isDefault: true,
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
