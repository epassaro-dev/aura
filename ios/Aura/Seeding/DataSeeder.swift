import Foundation
import OSLog
import SwiftData

enum DataSeeder {
    static func seed(context: ModelContext) {
        seedMedicines(context: context)
    }

    private static func seedMedicines(context: ModelContext) {
        let defaults: [(name: String, dosage: String)] = [
            ("Propranolol", "40 mg"),
            ("Topiramate", "25 mg"),
            ("Amitriptyline", "10 mg"),
            ("Valproate", "500 mg"),
            ("Magnesium", "400 mg"),
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
