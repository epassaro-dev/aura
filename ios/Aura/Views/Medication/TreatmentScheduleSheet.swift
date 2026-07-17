import SwiftUI
import SwiftData
import OSLog

struct TreatmentScheduleSheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    let medicine: Medicine
    var onSaved: () -> Void = {}
    @State private var timesPerDay = 1

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Label(medicine.name, systemImage: medicine.sfSymbol)
                            .font(.headline)
                        if let dosage = medicine.defaultDosage {
                            Spacer()
                            Text(dosage)
                        }
                    }
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
                        saveSchedule()
                        onSaved()
                    }
                }
            }
        }
    }

    private func saveSchedule() {
        context.insert(TreatmentPlanner.replaceSchedule(for: medicine, timesPerDay: timesPerDay))
        do {
            try context.save()
        } catch {
            Logger.persistence.error("Failed to save treatment schedule: \(String(describing: error), privacy: .public)")
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Medicine.self, configurations: config)
    let medicine = Medicine(name: "Propranolol", sfSymbol: "pills.fill", defaultDosage: "40mg")
    container.mainContext.insert(medicine)
    return TreatmentScheduleSheet(medicine: medicine)
        .modelContainer(container)
}
