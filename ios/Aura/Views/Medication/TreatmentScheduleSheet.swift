import SwiftUI
import SwiftData
import OSLog

struct TreatmentScheduleSheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    let medicine: Medicine
    var onSaved: () -> Void = {}
    @State private var timesPerDay = 1
    @State private var showSaveError = false

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
                    Button("Save") { save() }
                }
            }
            .alert("Couldn't Save Schedule", isPresented: $showSaveError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Something went wrong while saving. Your schedule hasn't been stored — please try again.")
            }
        }
    }

    private func save() {
        context.insert(TreatmentPlanner.replaceSchedule(for: medicine, timesPerDay: timesPerDay))
        do {
            try context.save()
            dismiss()
            onSaved()
        } catch {
            Logger.persistence.error("Failed to save treatment schedule: \(String(describing: error), privacy: .public)")
            // Discard the pending insert and the in-place deactivation of the
            // previous schedules so autosave can't persist them behind the user's back.
            context.rollback()
            showSaveError = true
        }
    }
}

#Preview(traits: .modifier(MedicationPreviewData())) {
    QueryPreview { (medicine: Medicine) in
        TreatmentScheduleSheet(medicine: medicine)
    }
}
