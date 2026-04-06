import SwiftUI

struct StressLogView: View {
    @EnvironmentObject private var viewModel: DailyLogViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var level: Double

    init() {
        _level = State(initialValue: 5)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(spacing: 16) {
                        Text("\(Int(level))")
                            .font(.system(size: 64, weight: .thin, design: .rounded))
                            .foregroundStyle(.indigo)

                        Slider(value: $level, in: 0...10, step: 1)
                            .tint(.indigo)

                        HStack {
                            Text("None")
                            Spacer()
                            Text("Extreme")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Stress Level (0 – 10)")
                }
            }
            .navigationTitle("Log Stress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
        }
        .onAppear {
            if let existing = viewModel.currentLog?.stressLevel {
                level = Double(existing)
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("Save") {
                viewModel.setStressLevel(Int(level))
                dismiss()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    StressLogView()
        .environmentObject(DailyLogViewModel.preview)
        .modelContainer(ModelContainer.preview)
}

