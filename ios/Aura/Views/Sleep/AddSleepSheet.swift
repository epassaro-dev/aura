import SwiftUI
import SwiftData

struct AddSleepSheet: View {
    private let context: ModelContext
    private let type: SleepType
    private let onSave: () -> Void

    @State private var startTime: Date
    @State private var endTime: Date
    @State private var quality: Int = 3
    @Environment(\.dismiss) private var dismiss

    init(context: ModelContext, type: SleepType, onSave: @escaping () -> Void) {
        self.context = context
        self.type = type
        self.onSave = onSave
        let now = Date.now
        let calendar = Calendar.current
        if type == .night {
            let yesterday = calendar.date(byAdding: .day, value: -1, to: now) ?? now
            var components = calendar.dateComponents([.year, .month, .day], from: yesterday)
            components.hour = 22
            components.minute = 0
            _startTime = State(wrappedValue: calendar.date(from: components) ?? yesterday)
            _endTime = State(wrappedValue: now)
        } else {
            _startTime = State(wrappedValue: calendar.date(byAdding: .hour, value: -1, to: now) ?? now)
            _endTime = State(wrappedValue: now)
        }
    }

    private var duration: TimeInterval {
        max(0, endTime.timeIntervalSince(startTime))
    }

    private var durationText: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
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
                    DatePicker("Start", selection: $startTime, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("End", selection: $endTime, displayedComponents: [.date, .hourAndMinute])
                    HStack {
                        Text("Duration")
                        Spacer()
                        Text(durationText)
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
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(endTime <= startTime)
                }
            }
        }
    }

    private func save() {
        let today = Calendar.current.startOfDay(for: .now)
        let entry = SleepEntry(
            date: today,
            type: type,
            startTime: startTime,
            endTime: endTime,
            quality: quality
        )
        context.insert(entry)
        try? context.save()
        onSave()
        dismiss()
    }
}

#Preview("Night sleep") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SleepEntry.self, configurations: config)
    return AddSleepSheet(context: container.mainContext, type: .night) {}
        .modelContainer(container)
}

#Preview("Nap") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SleepEntry.self, configurations: config)
    return AddSleepSheet(context: container.mainContext, type: .nap) {}
        .modelContainer(container)
}
