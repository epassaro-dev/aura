import SwiftUI
import SwiftData

struct MedicationLogView: View {
    @EnvironmentObject private var viewModel: DailyLogViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var dosage: String = ""
    @State private var takenAt: Date = .now
    @State private var isPreventive: Bool = false
    @State private var notes: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Medication") {
                    TextField("Name (e.g. Sumatriptan)", text: $name)
                        .autocorrectionDisabled()
                    TextField("Dosage (e.g. 50 mg)", text: $dosage)
                        .autocorrectionDisabled()
                    DatePicker("Taken at", selection: $takenAt, displayedComponents: [.hourAndMinute])
                    Toggle("Preventive medication", isOn: $isPreventive)
                }

                Section("Notes (optional)") {
                    TextField("Any observations…", text: $notes, axis: .vertical)
                        .lineLimit(3...)
                }
            }
            .navigationTitle("Log Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("Save") {
                let entry = MedicationEntry(
                    name: name,
                    dosage: dosage,
                    takenAt: takenAt,
                    isPreventive: isPreventive,
                    notes: notes
                )
                viewModel.addMedicationEntry(entry)
                dismiss()
            }
            .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }
}

// MARK: - Preview

#Preview {
    MedicationLogView()
        .environmentObject(DailyLogViewModel.preview)
        .modelContainer(ModelContainer.preview)
}

