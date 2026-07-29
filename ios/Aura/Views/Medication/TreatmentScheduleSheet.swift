import SwiftUI
import SwiftData
import OSLog

enum TreatmentScheduleSheetMode {
    case create(Medicine)
    case edit(TreatmentSchedule)
}

struct TreatmentScheduleSheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var timesPerDay = 1
    @State private var showSaveError = false
    @State private var dosage: Dosage?

    let medicine: Medicine
    let mode: TreatmentScheduleSheetMode
    var onSaved: () -> Void = {}

    init(mode: TreatmentScheduleSheetMode, onSaved: @escaping () -> Void) {
        self.onSaved = onSaved
        self.mode = mode

        switch mode {
        case .create(let medicine):
            self.medicine = medicine
            _dosage = State(initialValue: medicine.defaultDosage)
        case .edit(let schedule):
            self.medicine = schedule.medicine
            _timesPerDay = State(initialValue: schedule.timesPerDay)
            _dosage = State(initialValue: schedule.dosage ?? medicine.defaultDosage)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Label(medicine.name, systemImage: medicine.sfSymbol)
                        .font(.headline)
                }
                DosageSectionView(title: "Dosage", dosage: $dosage)
                Section("Daily schedule") {
                    Stepper(
                        timesPerDay == 1 ? "Once a day" : "\(timesPerDay) times a day",
                        value: $timesPerDay,
                        in: 1...10
                    )
                }
                if case .edit(let schedule) = mode {
                    Section {
                        Button("Stop treatment", role: .destructive) {
                            stopTreatment(schedule)
                        }
                    }
                }
            }
            .navigationTitle("Treatment Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", role: .confirm) { save() }
                }
            }
            .alert("Couldn't Save Schedule", isPresented: $showSaveError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Something went wrong while saving. Your changes haven't been stored — please try again.")
            }
        }
    }

    private func save() {
        context.insert(TreatmentPlanner.replaceSchedule(for: medicine, dosage: dosage, timesPerDay: timesPerDay))
        do {
            try context.save()
            dismiss()
            onSaved()
        } catch {
            Logger.persistence.error("Failed to save treatment schedule: \(String(describing: error), privacy: .public)")
            context.rollback()
            showSaveError = true
        }
    }

    private func stopTreatment(_ schedule: TreatmentSchedule) {
        schedule.stop()
        do {
            try context.save()
            dismiss()
            onSaved()
        } catch {
            Logger.persistence.error("Failed to stop treatment: \(String(describing: error), privacy: .public)")
            context.rollback()
            showSaveError = true
        }
    }
}

#Preview("Create", traits: .modifier(MedicinePreviewData())) {
    QueryPreview { (medicine: Medicine) in
        TreatmentScheduleSheet(mode: .create(medicine)) { }
    }
}

#Preview("Edit", traits: .modifier(TreatmentSchedulePreviewData())) {
    QueryPreview { (schedule: TreatmentSchedule) in
        TreatmentScheduleSheet(mode: .edit(schedule)) { }
    }
}
