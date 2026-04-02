import SwiftUI

struct SleepLogView: View {
    @EnvironmentObject private var viewModel: DailyLogViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var type:      SleepType    = .night
    @State private var quality:   SleepQuality = .average
    @State private var startTime: Date = Calendar.current.date(byAdding: .hour, value: -8, to: .now) ?? .now
    @State private var endTime:   Date = .now
    @State private var notes:     String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Type") {
                    Picker("Sleep Type", selection: $type) {
                        ForEach(SleepType.allCases, id: \.self) { t in
                            Text(t.rawValue).tag(t)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Duration") {
                    DatePicker("Start", selection: $startTime, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("End",   selection: $endTime,   displayedComponents: [.date, .hourAndMinute])

                    let dur = max(0, endTime.timeIntervalSince(startTime))
                    let h   = Int(dur) / 3600
                    let m   = (Int(dur) % 3600) / 60
                    HStack {
                        Text("Duration")
                        Spacer()
                        Text(h > 0 ? "\(h)h \(m)m" : "\(m)m")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Quality") {
                    Picker("Quality", selection: $quality) {
                        ForEach(SleepQuality.allCases, id: \.self) { q in
                            Label(q.label, systemImage: q.systemImage).tag(q)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Notes (optional)") {
                    TextField("Any observations…", text: $notes, axis: .vertical)
                        .lineLimit(3...)
                }
            }
            .navigationTitle("Log Sleep")
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
                let entry = SleepEntry(
                    startTime: startTime,
                    endTime:   endTime,
                    quality:   quality,
                    type:      type,
                    notes:     notes
                )
                viewModel.addSleepEntry(entry)
                dismiss()
            }
            .disabled(endTime <= startTime)
        }
    }
}
