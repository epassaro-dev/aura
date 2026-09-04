import SwiftUI
import SwiftData
import OSLog

struct MedicineCatalogSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @Query(filter: #Predicate<Medicine> { $0.isArchived == false }, sort: \Medicine.name)
    private var medicines: [Medicine]

    @State private var showAddMedicine = false
    @State private var editingEntry: Medicine?
    @State private var selectedMedicine: Medicine?

    var body: some View {
        NavigationStack {
            List {
                ForEach(medicines) { medicine in
                    Button {
                        selectedMedicine = medicine
                    } label: {
                        HStack {
                            Label(medicine.name, systemImage: medicine.sfSymbol)
                                .foregroundStyle(.primary)
                            if let dosage = medicine.defaultDosage {
                                Spacer()
                                Text(dosage.asString())
                            }
                        }
                    }
                    .contextMenu {
                        Button {
                            editingEntry = medicine
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        Button(role: .destructive) {
                            archive(medicine)
                        } label: {
                            Label("Archive", systemImage: "archivebox")
                        }
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
                    Button("Cancel", role: .cancel) { dismiss() }
                }
            }
            .sheet(isPresented: $showAddMedicine) {
                MedicineSheet(mode: .create)
            }
            .sheet(item: $editingEntry) { medicine in
                MedicineSheet(mode: .edit(medicine))
            }
            .sheet(item: $selectedMedicine) { medicine in
                TreatmentScheduleSheet(mode: .create(medicine)) {
                    dismiss()
                }
            }
        }
    }

    private func archive(_ medicine: Medicine) {
        medicine.archive()
        do {
            try context.save()
        } catch {
            Logger.persistence.error("Failed to archive medicine: \(String(describing: error), privacy: .public)")
        }
    }
}

#Preview("Empty", traits: .modifier(EmptyPreviewData())) {
    MedicineCatalogSheet()
}

#Preview("With medicines", traits: .modifier(MedicinePreviewData())) {
    MedicineCatalogSheet()
}
