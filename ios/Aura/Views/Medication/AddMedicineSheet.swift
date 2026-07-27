import SwiftUI

struct AddMedicineSheet: View {
    @Environment(\.dismiss) private var dismiss
    var onAdd: (String, Dosage?) -> Void
    @State private var name = ""
    @State private var dosage: Dosage?

    var body: some View {
        NavigationStack {
            Form {
                Section("Medicine name") {
                    TextField("e.g. Ibuprofen", text: $name)
                }
                DosageSectionView(title: "Default dosage (optional)", dosage: $dosage)
            }
            .navigationTitle("Add Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onAdd(name, $dosage.wrappedValue)
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
