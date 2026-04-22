import SwiftUI

private enum DosageUnit: String, CaseIterable {
    case mg, mcg, g, ml, IU, drops, tablet
}

struct AddMedicineSheet: View {
    @Environment(\.dismiss) private var dismiss
    var onAdd: (String, String?) -> Void
    @State private var name = ""
    @State private var dosageAmount = ""
    @State private var dosageUnit: DosageUnit = .mg

    private var combinedDosage: String? {
        let trimmed = dosageAmount.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }
        return "\(trimmed) \(dosageUnit.rawValue)"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Medicine name") {
                    TextField("e.g. Ibuprofen", text: $name)
                }
                Section("Default dosage (optional)") {
                    TextField("Amount", text: $dosageAmount)
                        .keyboardType(.decimalPad)
                    Picker("Unit", selection: $dosageUnit) {
                        ForEach(DosageUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                }
            }
            .navigationTitle("Add Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onAdd(name, combinedDosage)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddMedicineSheet { _, _ in }
}
