import SwiftUI
import SwiftData

struct MedicineCatalogSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: MedicineCatalogViewModel
    @State private var scheduleWasSaved = false
    var onScheduleSaved: () -> Void

    init(context: ModelContext, onScheduleSaved: @escaping () -> Void) {
        _viewModel = State(wrappedValue: MedicineCatalogViewModel(context: context))
        self.onScheduleSaved = onScheduleSaved
    }

    var body: some View {
        @Bindable var vm = viewModel
        NavigationStack {
            List {
                ForEach(vm.medicines) { medicine in
                    Button {
                        vm.selectedMedicine = medicine
                    } label: {
                        Label(medicine.name, systemImage: medicine.sfSymbol)
                            .foregroundStyle(.primary)
                    }
                }
                Button {
                    vm.showAddMedicine = true
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
            .sheet(isPresented: $vm.showAddMedicine) {
                AddMedicineSheet { name, dosage in
                    vm.addCustomMedicine(name: name, defaultDosage: dosage)
                }
            }
            .sheet(item: $vm.selectedMedicine) { medicine in
                TreatmentScheduleSheet(medicine: medicine) {
                    scheduleWasSaved = true
                }
            }
        }
        .onChange(of: scheduleWasSaved) { _, saved in
            if saved {
                dismiss()
                onScheduleSaved()
            }
        }
    }
}

#Preview("Empty") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Medicine.self, configurations: config)
    return MedicineCatalogSheet(context: container.mainContext, onScheduleSaved: {})
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
    return MedicineCatalogSheet(context: container.mainContext, onScheduleSaved: {})
}
