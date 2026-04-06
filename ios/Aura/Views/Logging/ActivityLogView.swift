import SwiftUI

struct ActivityLogView: View {
    @EnvironmentObject private var viewModel: DailyLogViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var type: ActivityType = .walking
    @State private var intensity: ActivityIntensity = .moderate
    @State private var durationMinutes: Double = 30
    @State private var notes: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Activity Type") {
                    Picker("Type", selection: $type) {
                        ForEach(ActivityType.allCases, id: \.self) { t in
                            Label(t.rawValue, systemImage: t.systemImage).tag(t)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Intensity") {
                    Picker("Intensity", selection: $intensity) {
                        ForEach(ActivityIntensity.allCases, id: \.self) { i in
                            Text(i.rawValue).tag(i)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    VStack(spacing: 12) {
                        Text("\(Int(durationMinutes)) min")
                            .font(.system(size: 48, weight: .thin, design: .rounded))
                            .foregroundStyle(.indigo)
                        Slider(value: $durationMinutes, in: 5...180, step: 5)
                            .tint(.indigo)
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Duration")
                }

                Section("Notes (optional)") {
                    TextField("Any observations…", text: $notes, axis: .vertical)
                        .lineLimit(3...)
                }
            }
            .navigationTitle("Log Activity")
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
                let entry = ActivityEntry(
                    type: type,
                    intensity: intensity,
                    durationMinutes: Int(durationMinutes),
                    notes: notes
                )
                viewModel.addActivityEntry(entry)
                dismiss()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ActivityLogView()
        .environmentObject(DailyLogViewModel.preview)
        .modelContainer(ModelContainer.preview)
}

