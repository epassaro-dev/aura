import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]

    var body: some View {
        NavigationStack {
            Group {
                if logs.isEmpty {
                    ContentUnavailableView(
                        "No History Yet",
                        systemImage: "calendar.badge.clock",
                        description: Text("Start logging today and your history will appear here.")
                    )
                } else {
                    List {
                        ForEach(logs) { log in
                            NavigationLink {
                                DailyLogDetailView(log: log)
                            } label: {
                                HistoryRowView(log: log)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("History")
        }
    }
}

// MARK: - Row

private struct HistoryRowView: View {
    let log: DailyLog

    private var dateText: String {
        if Calendar.current.isDateInToday(log.date) { return "Today" }
        if Calendar.current.isDateInYesterday(log.date) { return "Yesterday" }
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: log.date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(dateText)
                .font(.headline)
            HStack(spacing: 16) {
                if let stress = log.stressLevel {
                    Label("\(stress)/10", systemImage: "brain.head.profile")
                }
                if !log.sleepEntries.isEmpty {
                    Label("\(log.sleepEntries.count)", systemImage: "moon.fill")
                }
                if !log.migraineEpisodes.isEmpty {
                    Label("\(log.migraineEpisodes.count)", systemImage: "bolt.fill")
                        .foregroundStyle(.red)
                }
                if !log.headacheEpisodes.isEmpty {
                    Label("\(log.headacheEpisodes.count)", systemImage: "waveform.path.ecg")
                        .foregroundStyle(.orange)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Detail

struct DailyLogDetailView: View {
    let log: DailyLog

    var body: some View {
        List {
            // Stress
            if let stress = log.stressLevel {
                Section("Stress") {
                    Label("Level \(stress) / 10", systemImage: "brain.head.profile")
                }
            }

            // Sleep
            if !log.sleepEntries.isEmpty {
                Section("Sleep") {
                    ForEach(log.sleepEntries) { e in
                        VStack(alignment: .leading) {
                            Label("\(e.type.rawValue) – \(e.durationFormatted)", systemImage: e.quality.systemImage)
                            if !e.notes.isEmpty {
                                Text(e.notes).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }

            // Migraine
            if !log.migraineEpisodes.isEmpty {
                Section("Migraine") {
                    ForEach(log.migraineEpisodes) { ep in
                        VStack(alignment: .leading) {
                            Label("\(ep.area.rawValue) – Intensity \(ep.intensity)/10",
                                  systemImage: "bolt.fill")
                            if !ep.symptoms.isEmpty {
                                Text(ep.symptoms.joined(separator: ", "))
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }

            // Headache Episodes
            if !log.headacheEpisodes.isEmpty {
                Section("Headache") {
                    ForEach(log.headacheEpisodes) { ep in
                        VStack(alignment: .leading) {
                            Label("\(ep.type.rawValue) – Intensity \(ep.intensity)/10",
                                  systemImage: "waveform.path.ecg")
                            if !ep.symptoms.isEmpty {
                                Text(ep.symptoms.joined(separator: ", "))
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }

            // Headache Symptom Entries
            if !log.headacheSymptomEntries.isEmpty {
                Section("Headache Symptoms") {
                    ForEach(log.headacheSymptomEntries) { entry in
                        VStack(alignment: .leading) {
                            Label(entry.phase.rawValue, systemImage: entry.phase.systemImage)
                            if !entry.symptoms.isEmpty {
                                Text(entry.symptoms.joined(separator: ", "))
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }

            // Medications
            if !log.medicationEntries.isEmpty {
                Section("Medications") {
                    ForEach(log.medicationEntries) { e in
                        Label(
                            e.dosage.isEmpty ? e.name : "\(e.name) \(e.dosage)",
                            systemImage: "pill.fill"
                        )
                    }
                }
            }

            // Activity
            if !log.activityEntries.isEmpty {
                Section("Physical Activity") {
                    ForEach(log.activityEntries) { e in
                        Label("\(e.type.rawValue) – \(e.durationMinutes) min (\(e.intensity.rawValue))",
                              systemImage: e.type.systemImage)
                    }
                }
            }

            // Food
            if !log.foodEntries.isEmpty {
                Section("Food") {
                    ForEach(log.foodEntries) { e in
                        VStack(alignment: .leading) {
                            Label(e.mealType.rawValue, systemImage: e.mealType.systemImage)
                            if !e.items.isEmpty {
                                Text(e.items.joined(separator: ", "))
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }

            // Notes
            if !log.notes.isEmpty {
                Section("Notes") {
                    ForEach(log.notes) { note in
                        Text(note.content)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(formattedDate)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var formattedDate: String {
        let f = DateFormatter()
        f.dateStyle = .long
        return f.string(from: log.date)
    }
}

// MARK: - Preview

#Preview("History – empty") {
    HistoryView()
        .modelContainer(ModelContainer.preview)
}

#Preview("History – with data") {
    let container = ModelContainer.preview
    return HistoryView()
        .environmentObject(DailyLogViewModel.preview)
        .modelContainer(container)
}

