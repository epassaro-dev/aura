import Foundation
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
            guard ((try? context.fetch(descriptor)) ?? []).isEmpty else { continue }
            context.insert(Medicine(
                name: entry.name,
                sfSymbol: "pills.fill",
                isDefault: true,
                defaultDosage: entry.dosage
            ))
        }

        try? context.save()
    }
}
