import SwiftUI
import SwiftData
import OSLog

struct SleepSectionView: View {
    @Environment(\.modelContext) private var context
    @Query private var entries: [SleepEntry]
    @State private var showAddNight = false
    @State private var showAddNap = false

    init(day: Date, nextDay: Date) {
        _entries = Query(filter: #Predicate<SleepEntry> { entry in
            entry.date >= day && entry.date < nextDay
        })
    }

    private var sleepDay: SleepDay {
        SleepDay(entries: entries)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sleep")
                .font(.headline)

            if let night = sleepDay.nightSleep {
                sleepRow(entry: night)
            } else {
                Button("Log night sleep") {
                    showAddNight = true
                }
                .buttonStyle(.borderedProminent)
            }

            ForEach(sleepDay.naps) { nap in
                sleepRow(entry: nap)
            }

            Button("Add nap") {
                showAddNap = true
            }
            .buttonStyle(.bordered)
        }
        .sheet(isPresented: $showAddNight) {
            AddSleepSheet(type: .night)
        }
        .sheet(isPresented: $showAddNap) {
            AddSleepSheet(type: .nap)
        }
    }

    @ViewBuilder
    private func sleepRow(entry: SleepEntry) -> some View {
        HStack(spacing: 12) {
            Image(systemName: entry.type == .night ? "moon.fill" : "zzz")
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.type == .night ? "Night sleep" : "Nap")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(durationText(for: entry) + " · " + qualityStars(entry.quality))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
        .contextMenu {
            Button(role: .destructive) {
                delete(entry)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private func delete(_ entry: SleepEntry) {
        context.delete(entry)
        do {
            try context.save()
        } catch {
            Logger.persistence.error("Failed to delete sleep entry: \(String(describing: error), privacy: .public)")
        }
    }

    private func durationText(for entry: SleepEntry) -> String {
        SleepDay.durationText(from: entry.endTime.timeIntervalSince(entry.startTime))
    }

    private func qualityStars(_ quality: Int) -> String {
        String(repeating: "★", count: quality) + String(repeating: "☆", count: 5 - quality)
    }
}

#Preview("Empty state", traits: .modifier(EmptyPreviewData())) {
    let today = Calendar.current.startOfDay(for: .now)
    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
    SleepSectionView(day: today, nextDay: tomorrow)
        .padding()
}

#Preview("Night sleep logged", traits: .modifier(NightSleepPreviewData())) {
    let today = Calendar.current.startOfDay(for: .now)
    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
    SleepSectionView(day: today, nextDay: tomorrow)
        .padding()
}

#Preview("Night sleep and nap", traits: .modifier(FullSleepPreviewData())) {
    let today = Calendar.current.startOfDay(for: .now)
    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
    SleepSectionView(day: today, nextDay: tomorrow)
        .padding()
}
