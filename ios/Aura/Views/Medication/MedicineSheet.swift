import OSLog
import SwiftUI

enum MedicineSheetMode {
    case create
    case edit(Medicine)
}

struct MedicineSheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    private let mode: MedicineSheetMode
    private let title: String

    @State private var name = ""
    @State private var dosage: Dosage?
    @State private var sfSymbol = "pills.fill"

    init(mode: MedicineSheetMode) {
        self.mode = mode
        switch mode {
        case .create:
            self.title = "Add Medication"
        case .edit(let medicine):
            self.title = "Edit Medication"
            _name = State(initialValue: medicine.name)
            _dosage = State(initialValue: medicine.defaultDosage)
            _sfSymbol = State(initialValue: medicine.sfSymbol)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Medicine name") {
                    TextField("e.g. Ibuprofen", text: $name)
                }
                DosageSectionView(
                    title: "Default dosage (optional)",
                    dosage: $dosage
                )
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", role: .confirm) {
                        save()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        switch mode {
        case .create:
            let medicine = Medicine(
                name: name.trimmingCharacters(in: .whitespaces),
                sfSymbol: sfSymbol,
                defaultDosage: dosage
            )
            context.insert(medicine)
        case .edit(let medicine):
            medicine.name = name.trimmingCharacters(in: .whitespaces)
            medicine.defaultDosage = dosage
            medicine.sfSymbol = sfSymbol
        }

        do {
            try context.save()
            dismiss()
        } catch {
            Logger.persistence.error(
                "Failed to save medicine: \(String(describing: error), privacy: .public)"
            )
            // Remove the pending insert so autosave can't persist or retry it behind the user's back.
            context.rollback()
        }
    }
}

#Preview("Create") {
    MedicineSheet(mode: .create)
}

#Preview("Edit", traits: .modifier(MedicationPreviewData())) {
    QueryPreview { (medicine: Medicine) in
        MedicineSheet(mode: .edit(medicine))
    }
}
