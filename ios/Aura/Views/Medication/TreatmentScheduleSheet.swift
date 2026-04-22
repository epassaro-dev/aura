import SwiftUI
import SwiftData

struct TreatmentScheduleSheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    let medicine: Medicine
    var onSave: () -> Void
    @State private var timesPerDay = 1

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Label(medicine.name, systemImage: medicine.sfSymbol)
                        .font(.headline)
                }
                Section("Daily schedule") {
                    Stepper(
                        timesPerDay == 1 ? "Once a day" : "\(timesPerDay) times a day",
                        value: $timesPerDay,
                        in: 1...10
                    )
                }
            }
            .navigationTitle("Treatment Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let vm = TreatmentScheduleViewModel(context: context, medicine: medicine)
                        vm.timesPerDay = timesPerDay
                        vm.save()
                        onSave()
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Medicine.self, configurations: config)
    let medicine = Medicine(name: "Propranolol", sfSymbol: "pills.fill", defaultDosage: "40mg")
    container.mainContext.insert(medicine)
    return TreatmentScheduleSheet(medicine: medicine, onSave: {})
        .modelContainer(container)
}
