import SwiftUI
import SwiftData
import OSLog

enum LogSleepSheetMode {
    case create(SleepType)
    case edit(SleepEntry)
}

struct LogSleepSheet: View {
    private let mode: LogSleepSheetMode
    private let type: SleepType

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var quality: Int = 3
    @State private var showSaveError = false

    init(mode: LogSleepSheetMode) {
        self.mode = mode
        let now = Date.now
        let calendar = Calendar.current

        switch mode {
        case .create(let type):
            self.type = type
            if type == .night {
                let yesterday = calendar.date(byAdding: .day, value: -1, to: now) ?? now
                var startComponents = calendar.dateComponents([.year, .month, .day], from: yesterday)
                startComponents.hour = 23
                startComponents.minute = 0
                let startDate = calendar.date(from: startComponents) ?? yesterday
                let endDate = calendar.date(byAdding: .hour, value: 8, to: startDate) ?? now
                _startTime = State(wrappedValue: startDate)
                _endTime = State(wrappedValue: endDate)
            } else {
                _startTime = State(wrappedValue: calendar.date(byAdding: .hour, value: -1, to: now) ?? now)
                _endTime = State(wrappedValue: now)
            }
        case .edit(let entry):
            self.type = entry.type
            _startTime = State(wrappedValue: entry.startTime)
            _endTime = State(wrappedValue: entry.endTime)
            _quality = State(wrappedValue: entry.quality)
        }
    }

    private var duration: TimeInterval {
        max(0, endTime.timeIntervalSince(startTime))
    }

    private var qualityLabel: String {
        switch quality {
        case 1: return "Poor"
        case 2: return "Fair"
        case 3: return "Good"
        case 4: return "Great"
        case 5: return "Excellent"
        default: return ""
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Time") {
                    DatePicker("Start", selection: $startTime, in: ...Date.now, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("End", selection: $endTime, in: ...Date.now, displayedComponents: [.date, .hourAndMinute])
                    HStack {
                        Text("Duration")
                        Spacer()
                        Text(SleepDay.durationText(from: duration))
                            .foregroundStyle(.secondary)
                    }
                }
                Section("Quality") {
                    HStack(spacing: 8) {
                        ForEach(1...5, id: \.self) { star in
                            Button {
                                quality = star
                            } label: {
                                Image(systemName: star <= quality ? "star.fill" : "star")
                                    .font(.title2)
                                    .foregroundStyle(star <= quality ? .yellow : .secondary)
                            }
                            .buttonStyle(.plain)
                        }
                        Spacer()
                        Text(qualityLabel)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(type == .night ? "Log Night Sleep" : "Log Nap")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", role: .confirm) { save() }
                        .disabled(endTime <= startTime)
                }
            }
            .alert("Couldn't Save Sleep Entry", isPresented: $showSaveError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Something went wrong while saving. Your entry hasn't been stored — please try again.")
            }
        }
    }

    private func save() {
        switch mode {
        case .create:
            let entry = SleepEntry(
                date: SleepDay.dayAnchor(forSleepEnding: endTime),
                type: type,
                startTime: startTime,
                endTime: endTime,
                quality: quality
            )
            context.insert(entry)
        case .edit(let entry):
            entry.date = SleepDay.dayAnchor(forSleepEnding: endTime)
            entry.startTime = startTime
            entry.endTime = endTime
            entry.quality = quality
        }

        do {
            try context.save()
            // TODO: show a confirmation toast naming the anchored day (e.g. "Night sleep logged for Jul 10"),
            // reusable across log flows; evaluate idiomatic SwiftUI presentation options first.
            dismiss()
        } catch {
            Logger.persistence.error("Failed to save sleep entry: \(String(describing: error), privacy: .public)")
            // Remove the pending insert so autosave can't persist or retry it behind the user's back.
            context.rollback()
            showSaveError = true
        }
    }
}

#Preview("Night sleep", traits: .modifier(EmptyPreviewData())) {
    LogSleepSheet(mode: .create(.night))
}

#Preview("Nap", traits: .modifier(EmptyPreviewData())) {
    LogSleepSheet(mode: .create(.nap))
}

#Preview("Edit night sleep", traits: .modifier(NightSleepPreviewData())) {
    QueryPreview { (entry: SleepEntry) in
        LogSleepSheet(mode: .edit(entry))
    }
}
