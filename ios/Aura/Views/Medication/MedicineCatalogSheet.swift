import SwiftUI
import SwiftData
import OSLog

struct MedicineCatalogSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(filter: #Predicate<Medicine> { $0.isArchived == false }, sort: \Medicine.name)
    private var medicines: [Medicine]
    @State private var showAddMedicine = false
    @State private var selectedMedicine: Medicine?

    var body: some View {
        NavigationStack {
            List {
                ForEach(medicines) { medicine in
                    Button {
                        selectedMedicine = medicine
                    } label: {
                        Label(medicine.name, systemImage: medicine.sfSymbol)
                            .foregroundStyle(.primary)
                    }
                }
                Button {
                    showAddMedicine = true
                } label: {
                    Label("Add medication", systemImage: "plus.circle")
                }
            }
            .navigationTitle("Select Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showAddMedicine) {
                AddMedicineSheet { name, dosage in
                    addMedicine(name: name, dosage: dosage)
                }
            }
            .sheet(item: $selectedMedicine) { medicine in
                TreatmentScheduleSheet(medicine: medicine) {
                    dismiss()
                }
            }
        }
    }

    private func addMedicine(name: String, dosage: String?) {
        guard let medicine = TreatmentPlanner.makeMedicine(name: name, defaultDosage: dosage) else { return }
        context.insert(medicine)
        do {
            try context.save()
        } catch {
            Logger.persistence.error("Failed to add medicine: \(String(describing: error), privacy: .public)")
        }
    }
}

#Preview("Empty", traits: .modifier(EmptyPreviewData())) {
    MedicineCatalogSheet()
}

#Preview("With medicines", traits: .modifier(MedicationPreviewData())) {
    MedicineCatalogSheet()
}
