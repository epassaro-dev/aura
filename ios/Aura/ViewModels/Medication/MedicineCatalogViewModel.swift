import Foundation
import SwiftData

@Observable final class MedicineCatalogViewModel {
    private let context: ModelContext
    var medicines: [Medicine] = []
    var showAddMedicine = false
    var selectedMedicine: Medicine?

    init(context: ModelContext) {
        self.context = context
        fetchMedicines()
    }

    func fetchMedicines() {
        let descriptor = FetchDescriptor<Medicine>(
            predicate: #Predicate<Medicine> { medicine in
                medicine.isArchived == false
            },
            sortBy: [SortDescriptor(\.name)]
        )
        medicines = (try? context.fetch(descriptor)) ?? []
    }

    func addCustomMedicine(name: String, defaultDosage: String?) {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        let trimmedDosage = defaultDosage?.trimmingCharacters(in: .whitespaces)
        let finalDosage = (trimmedDosage?.isEmpty == false) ? trimmedDosage : nil
        let medicine = Medicine(name: trimmedName, sfSymbol: "pills.fill", defaultDosage: finalDosage)
        context.insert(medicine)
        try? context.save()
        fetchMedicines()
    }
}
