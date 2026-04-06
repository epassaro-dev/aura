import SwiftUI
import SwiftData

struct HeadacheEpisodeLogView: View {
    @EnvironmentObject private var viewModel: DailyLogViewModel
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \CustomSymptom.name) private var customSymptoms: [CustomSymptom]

    @State private var type: HeadacheType = .tensionHeadache
    @State private var area: HeadacheArea = .unspecified
    @State private var intensity: Double = 5
    @State private var startTime: Date = .now
    @State private var isOngoing: Bool = true
    @State private var endTime: Date = .now
    @State private var selectedSymptoms: Set<String> = []
    @State private var triggerText: String = ""
    @State private var triggers: [String] = []
    @State private var notes: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Type & Location") {
                    Picker("Type", selection: $type) {
                        ForEach(HeadacheType.allCases, id: \.self) { t in
                            Text(t.rawValue).tag(t)
                        }
                    }
                    Picker("Area", selection: $area) {
                        ForEach(HeadacheArea.allCases, id: \.self) { a in
                            Text(a.rawValue).tag(a)
                        }
                    }
                }

                Section {
                    VStack(spacing: 10) {
                        Text("\(Int(intensity)) / 10")
                            .font(.system(size: 48, weight: .thin, design: .rounded))
                            .foregroundStyle(intensityColor)
                        Slider(value: $intensity, in: 1...10, step: 1)
                            .tint(intensityColor)
                    }
                    .padding(.vertical, 6)
                } header: {
                    Text("Pain Intensity")
                }

                Section("Timing") {
                    DatePicker("Started", selection: $startTime, displayedComponents: [.date, .hourAndMinute])
                    Toggle("Still ongoing", isOn: $isOngoing)
                    if !isOngoing {
                        DatePicker("Ended", selection: $endTime,
                                   in: startTime..., displayedComponents: [.date, .hourAndMinute])
                    }
                }

                if !customSymptoms.isEmpty {
                    Section {
                        ForEach(customSymptoms) { symptom in
                            symptomToggle(name: symptom.name)
                        }
                    } header: {
                        Text("Symptoms")
                    } footer: {
                        Text("Add new symptom types in Settings.")
                    }
                }

                Section {
                    ForEach(triggers, id: \.self) { t in Text(t) }
                        .onDelete { triggers.remove(atOffsets: $0) }
                    HStack {
                        TextField("Add trigger…", text: $triggerText)
                            .autocorrectionDisabled()
                            .onSubmit { addTrigger() }
                        Button(action: addTrigger) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.indigo)
                        }
                        .disabled(triggerText.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                } header: {
                    Text("Possible Triggers")
                }

                Section("Notes (optional)") {
                    TextField("Any observations…", text: $notes, axis: .vertical)
                        .lineLimit(3...)
                }
            }
            .navigationTitle("Log Headache")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
        }
    }

    private var intensityColor: Color {
        switch Int(intensity) {
        case 1...3: return .green
        case 4...6: return .orange
        default: return .red
        }
    }

    private func addTrigger() {
        let t = triggerText.trimmingCharacters(in: .whitespaces)
        guard !t.isEmpty else { return }
        triggers.append(t)
        triggerText = ""
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
                let episode = HeadacheEpisode(
                    type: type,
                    area: area,
                    intensity: Int(intensity),
                    startTime: startTime,
                    symptoms: Array(selectedSymptoms),
                    triggers: triggers,
                    notes: notes
                )
                if !isOngoing { episode.endTime = endTime }
                viewModel.addHeadacheEpisode(episode)
                dismiss()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    HeadacheEpisodeLogView()
        .environmentObject(DailyLogViewModel.preview)
        .modelContainer(ModelContainer.preview)
}
