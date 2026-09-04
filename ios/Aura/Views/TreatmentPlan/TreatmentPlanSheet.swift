import SwiftUI
import SwiftData
import OSLog

enum TreatmentPlanSheetMode {
    case create(Medicine)
    case edit(TreatmentPlan)
}

struct TreatmentPlanSheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var timesPerDay = 1
    @State private var showSaveError = false
    @State private var dosage: Dosage?

    let medicine: Medicine
    let mode: TreatmentPlanSheetMode
    var onSaved: () -> Void = {}

    init(mode: TreatmentPlanSheetMode, onSaved: @escaping () -> Void) {
        self.onSaved = onSaved
        self.mode = mode

        switch mode {
        case .create(let medicine):
            self.medicine = medicine
            _dosage = State(initialValue: medicine.defaultDosage)
        case .edit(let plan):
            self.medicine = plan.medicine
            _timesPerDay = State(initialValue: plan.timesPerDay)
            _dosage = State(initialValue: plan.dosage ?? medicine.defaultDosage)
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
                Section("Daily plan") {
                    Stepper(
                        timesPerDay == 1 ? "Once a day" : "\(timesPerDay) times a day",
                        value: $timesPerDay,
                        in: 1...10
                    )
                }
                if case .edit(let plan) = mode {
                    Section {
                        Button("Stop treatment", role: .destructive) {
                            stopTreatment(plan)
                        }
                    }
                }
            }
            .navigationTitle("Treatment Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", role: .confirm) { save() }
                }
            }
            .alert("Couldn't Save Plan", isPresented: $showSaveError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Something went wrong while saving. Your changes haven't been stored — please try again.")
            }
        }
    }

    private func save() {
        context.insert(TreatmentPlanner.replacePlan(for: medicine, dosage: dosage, timesPerDay: timesPerDay))
        do {
            try context.save()
            dismiss()
            onSaved()
        } catch {
            Logger.persistence.error("Failed to save treatment plan: \(String(describing: error), privacy: .public)")
            context.rollback()
            showSaveError = true
        }
    }

    private func stopTreatment(_ plan: TreatmentPlan) {
        plan.stop()
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
        TreatmentPlanSheet(mode: .create(medicine)) { }
    }
}

#Preview("Edit", traits: .modifier(TreatmentPlanPreviewData())) {
    QueryPreview { (plan: TreatmentPlan) in
        TreatmentPlanSheet(mode: .edit(plan)) { }
    }
}
