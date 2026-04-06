import SwiftUI
import SwiftData

struct HeadacheSymptomLogView: View {
    @EnvironmentObject private var viewModel: DailyLogViewModel
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \CustomSymptom.name) private var customSymptoms: [CustomSymptom]

    @State private var phase: EpisodePhase = .prodrome
    @State private var selectedSymptoms: Set<String> = []
    @State private var notes: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Phase", selection: $phase) {
                        ForEach(EpisodePhase.allCases, id: \.self) { p in
                            Label(p.rawValue, systemImage: p.systemImage).tag(p)
                        }
                    }
                    .pickerStyle(.menu)
                } header: {
                    Text("Episode Phase")
                } footer: {
                    Text(phase.description)
                }

                Section {
                    ForEach(MigraineSymptom.allCases, id: \.self) { symptom in
                        symptomToggle(name: symptom.rawValue)
                    }
                    if !customSymptoms.isEmpty {
                        Divider()
                        ForEach(customSymptoms) { symptom in
                            symptomToggle(name: symptom.name)
                        }
                    }
                } header: {
                    Text("Symptoms")
                } footer: {
                    Text("Add new symptom types in Settings.")
                }

                Section("Notes (optional)") {
                    TextField("Any observations…", text: $notes, axis: .vertical)
                        .lineLimit(3...)
                }
            }
            .navigationTitle("Log Headache Symptoms")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
        }
    }

    @ViewBuilder
    private func symptomToggle(name: String) -> some View {
        Toggle(name, isOn: Binding(
            get: { selectedSymptoms.contains(name) },
            set: { on in
                if on { selectedSymptoms.insert(name) }
                else { selectedSymptoms.remove(name) }
            }
        ))
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("Save") {
                let entry = HeadacheSymptomEntry(
                    phase: phase,
                    symptoms: Array(selectedSymptoms),
                    notes: notes
                )
                viewModel.addHeadacheSymptomEntry(entry)
                dismiss()
            }
            .disabled(selectedSymptoms.isEmpty)
        }
    }
}

// MARK: - Preview

#Preview {
    HeadacheSymptomLogView()
        .environmentObject(DailyLogViewModel.preview)
        .modelContainer(ModelContainer.preview)
}
