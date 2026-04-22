import SwiftUI
import SwiftData

struct SleepSectionView: View {
    private let context: ModelContext
    @State private var viewModel: SleepSectionViewModel

    init(context: ModelContext) {
        self.context = context
        _viewModel = State(wrappedValue: SleepSectionViewModel(context: context))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sleep")
                .font(.headline)

            if let night = viewModel.nightSleep {
                sleepRow(entry: night)
            } else {
                Button("Log night sleep") {
                    viewModel.showAddNight = true
                }
                .buttonStyle(.borderedProminent)
            }

            ForEach(viewModel.naps) { nap in
                sleepRow(entry: nap)
            }

            Button("Add nap") {
                viewModel.showAddNap = true
            }
            .buttonStyle(.bordered)
        }
        .sheet(isPresented: $viewModel.showAddNight) {
            AddSleepSheet(context: context, type: .night) {
                viewModel.fetch()
            }
        }
        .sheet(isPresented: $viewModel.showAddNap) {
            AddSleepSheet(context: context, type: .nap) {
                viewModel.fetch()
            }
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
                viewModel.delete(entry)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private func durationText(for entry: SleepEntry) -> String {
        let interval = entry.endTime.timeIntervalSince(entry.startTime)
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }

    private func qualityStars(_ quality: Int) -> String {
        String(repeating: "★", count: quality) + String(repeating: "☆", count: 5 - quality)
    }
}

#Preview("Empty state") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SleepEntry.self, configurations: config)
    return SleepSectionView(context: container.mainContext)
        .modelContainer(container)
        .padding()
}

#Preview("Night sleep logged") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SleepEntry.self, configurations: config)
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: .now)
    let start = calendar.date(byAdding: .hour, value: -8, to: .now) ?? .now
    let entry = SleepEntry(date: today, type: .night, startTime: start, endTime: .now, quality: 4)
    container.mainContext.insert(entry)
    return SleepSectionView(context: container.mainContext)
        .modelContainer(container)
        .padding()
}

#Preview("Night sleep and nap") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SleepEntry.self, configurations: config)
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: .now)
    let nightStart = calendar.date(byAdding: .hour, value: -9, to: .now) ?? .now
    let nightEnd = calendar.date(byAdding: .hour, value: -1, to: .now) ?? .now
    let night = SleepEntry(date: today, type: .night, startTime: nightStart, endTime: nightEnd, quality: 3)
    let napStart = calendar.date(byAdding: .minute, value: -45, to: .now) ?? .now
    let nap = SleepEntry(date: today, type: .nap, startTime: napStart, endTime: .now, quality: 5)
    container.mainContext.insert(night)
    container.mainContext.insert(nap)
    return SleepSectionView(context: container.mainContext)
        .modelContainer(container)
        .padding()
}
