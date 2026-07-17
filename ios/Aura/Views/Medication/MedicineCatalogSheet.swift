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

#Preview("Empty") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Medicine.self, configurations: config)
    return MedicineCatalogSheet()
        .modelContainer(container)
}

#Preview("With medicines") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Medicine.self, configurations: config)
    let medicines = [
        Medicine(name: "Propranolol", sfSymbol: "pills.fill", defaultDosage: "40mg"),
        Medicine(name: "Topiramate", sfSymbol: "pills.fill", defaultDosage: "25mg"),
        Medicine(name: "Amitriptyline", sfSymbol: "pills.fill"),
    ]
    medicines.forEach { container.mainContext.insert($0) }
    return MedicineCatalogSheet()
        .modelContainer(container)
}
