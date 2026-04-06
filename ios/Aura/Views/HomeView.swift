import SwiftUI
import SwiftData

// MARK: - HomeView

struct HomeView: View {
    @EnvironmentObject private var viewModel: DailyLogViewModel
    @Query private var allLogs: [DailyLog]
    @State private var showingQuickLog = false

    private var todaysLog: DailyLog? {
        allLogs.first { Calendar.current.isDateInToday($0.date) }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 16) {
                        if let log = todaysLog {
                            StressSummaryCard(log: log)
                            SleepSummaryCard(log: log)
                            MigraineSummaryCard(log: log)
                            HeadacheEpisodeSummaryCard(log: log)
                            HeadacheSymptomSummaryCard(log: log)
                            MedicationSummaryCard(log: log)
                            ActivitySummaryCard(log: log)
                            FoodSummaryCard(log: log)
                            NotesSummaryCard(log: log)
                        } else {
                            EmptyDayView()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 100)
                }

                // One-tap logging button
                Button {
                    showingQuickLog = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .fontWeight(.bold)
                        Text("Log")
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 15)
                    .background(Color.indigo)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
                    .shadow(color: Color.indigo.opacity(0.35), radius: 10, y: 5)
                }
                .accessibilityIdentifier("quickLogButton")
                .padding(.bottom, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(formattedDate)
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.fetchOrCreateTodaysLog()
            }
        }
        .sheet(isPresented: $showingQuickLog) {
            QuickLogView()
                .environmentObject(viewModel)
        }
    }

    private var formattedDate: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f.string(from: .now)
    }
}

// MARK: - EmptyDayView

private struct EmptyDayView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "moon.stars")
                .font(.system(size: 52))
                .foregroundStyle(Color.indigo.opacity(0.5))
            Text("Nothing logged yet")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("Tap **Log** to start tracking your day.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
    }
}

// MARK: - Summary Cards

private struct SummaryCard<Content: View>: View {
    let title: String
    let systemImage: String
    let content: Content

    init(
        title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.systemImage = systemImage
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: Stress

private struct StressSummaryCard: View {
    let log: DailyLog
    @EnvironmentObject private var viewModel: DailyLogViewModel
    @State private var showingLog = false

    var body: some View {
        SummaryCard(title: "Stress", systemImage: "brain.head.profile") {
            if let level = log.stressLevel {
                HStack {
                    Text("\(level) / 10")
                        .font(.title2.weight(.semibold))
                    Spacer()
                    Button("Edit") { showingLog = true }
                        .font(.subheadline)
                        .foregroundStyle(.indigo)
                }
            } else {
                addButton { showingLog = true }
            }
        }
        .sheet(isPresented: $showingLog) {
            StressLogView()
                .environmentObject(viewModel)
        }
    }
}

// MARK: Sleep

private struct SleepSummaryCard: View {
    let log: DailyLog
    @EnvironmentObject private var viewModel: DailyLogViewModel
    @State private var showingLog = false

    var body: some View {
        SummaryCard(title: "Sleep", systemImage: "moon.fill") {
            if log.sleepEntries.isEmpty {
                addButton { showingLog = true }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(log.sleepEntries) { entry in
                        HStack {
                            Image(systemName: entry.quality.systemImage)
                            Text("\(entry.type.rawValue) – \(entry.durationFormatted)")
                                .font(.subheadline)
                            Spacer()
                        }
                    }
                }
                Button("Add more") { showingLog = true }
                    .font(.subheadline)
                    .foregroundStyle(.indigo)
                    .padding(.top, 2)
            }
        }
        .sheet(isPresented: $showingLog) {
            SleepLogView()
                .environmentObject(viewModel)
        }
    }
}

// MARK: Migraine

private struct MigraineSummaryCard: View {
    let log: DailyLog
    @EnvironmentObject private var viewModel: DailyLogViewModel
    @State private var showingLog = false

    var body: some View {
        SummaryCard(title: "Migraine", systemImage: "bolt.fill") {
            if log.migraineEpisodes.isEmpty {
                addButton { showingLog = true }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(log.migraineEpisodes) { ep in
                        HStack {
                            Text(ep.area.rawValue)
                                .font(.subheadline)
                            Spacer()
                            Text("Intensity \(ep.intensity)/10")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                Button("Add more") { showingLog = true }
                    .font(.subheadline)
                    .foregroundStyle(.indigo)
                    .padding(.top, 2)
            }
        }
        .sheet(isPresented: $showingLog) {
            MigraineEpisodeLogView()
                .environmentObject(viewModel)
        }
    }
}

// MARK: Headache Episode

private struct HeadacheEpisodeSummaryCard: View {
    let log: DailyLog
    @EnvironmentObject private var viewModel: DailyLogViewModel
    @State private var showingLog = false

    var body: some View {
        SummaryCard(title: "Headache", systemImage: "waveform.path.ecg") {
            if log.headacheEpisodes.isEmpty {
                addButton { showingLog = true }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(log.headacheEpisodes) { ep in
                        HStack {
                            Text(ep.type.rawValue)
                                .font(.subheadline)
                            Spacer()
                            Text("Intensity \(ep.intensity)/10")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                Button("Add more") { showingLog = true }
                    .font(.subheadline)
                    .foregroundStyle(.indigo)
                    .padding(.top, 2)
            }
        }
        .sheet(isPresented: $showingLog) {
            HeadacheEpisodeLogView()
                .environmentObject(viewModel)
        }
    }
}

// MARK: Headache Symptoms (Prodrome / Postdrome)

private struct HeadacheSymptomSummaryCard: View {
    let log: DailyLog
    @EnvironmentObject private var viewModel: DailyLogViewModel
    @State private var showingLog = false

    var body: some View {
        SummaryCard(title: "Headache Symptoms", systemImage: "exclamationmark.triangle.fill") {
            if log.headacheSymptomEntries.isEmpty {
                addButton { showingLog = true }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(log.headacheSymptomEntries) { entry in
                        HStack {
                            Image(systemName: entry.phase.systemImage)
                                .foregroundStyle(.orange)
                            Text(entry.phase.rawValue)
                                .font(.subheadline)
                            Spacer()
                            Text("\(entry.symptoms.count) symptom(s)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                Button("Add more") { showingLog = true }
                    .font(.subheadline)
                    .foregroundStyle(.indigo)
                    .padding(.top, 2)
            }
        }
        .sheet(isPresented: $showingLog) {
            HeadacheSymptomLogView()
                .environmentObject(viewModel)
        }
    }
}

// MARK: Medication

private struct MedicationSummaryCard: View {
    let log: DailyLog
    @EnvironmentObject private var viewModel: DailyLogViewModel
    @State private var showingLog = false

    var body: some View {
        SummaryCard(title: "Medications", systemImage: "pill.fill") {
            if log.medicationEntries.isEmpty {
                addButton { showingLog = true }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(log.medicationEntries) { entry in
                        HStack {
                            Text(entry.name)
                                .font(.subheadline)
                            if !entry.dosage.isEmpty {
                                Text("–")
                                Text(entry.dosage)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                Button("Add more") { showingLog = true }
                    .font(.subheadline)
                    .foregroundStyle(.indigo)
                    .padding(.top, 2)
            }
        }
        .sheet(isPresented: $showingLog) {
            MedicationLogView()
                .environmentObject(viewModel)
        }
    }
}

// MARK: Activity

private struct ActivitySummaryCard: View {
    let log: DailyLog
    @EnvironmentObject private var viewModel: DailyLogViewModel
    @State private var showingLog = false

    var body: some View {
        SummaryCard(title: "Physical Activity", systemImage: "figure.run") {
            if log.activityEntries.isEmpty {
                addButton { showingLog = true }
            } else {
                let total = log.activityEntries.reduce(0) { $0 + $1.durationMinutes }
                HStack {
                    Text("\(total) min total")
                        .font(.title2.weight(.semibold))
                    Spacer()
                    Button("Add more") { showingLog = true }
                        .font(.subheadline)
                        .foregroundStyle(.indigo)
                }
            }
        }
        .sheet(isPresented: $showingLog) {
            ActivityLogView()
                .environmentObject(viewModel)
        }
    }
}

// MARK: Food

private struct FoodSummaryCard: View {
    let log: DailyLog
    @EnvironmentObject private var viewModel: DailyLogViewModel
    @State private var showingLog = false

    var body: some View {
        SummaryCard(title: "Food", systemImage: "fork.knife") {
            if log.foodEntries.isEmpty {
                addButton { showingLog = true }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(log.foodEntries) { entry in
                        HStack {
                            Image(systemName: entry.mealType.systemImage)
                                .foregroundStyle(.secondary)
                            Text(entry.mealType.rawValue)
                                .font(.subheadline)
                            Spacer()
                            Text("\(entry.items.count) item(s)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                Button("Add more") { showingLog = true }
                    .font(.subheadline)
                    .foregroundStyle(.indigo)
                    .padding(.top, 2)
            }
        }
        .sheet(isPresented: $showingLog) {
            FoodLogView()
                .environmentObject(viewModel)
        }
    }
}

// MARK: Notes

private struct NotesSummaryCard: View {
    let log: DailyLog
    @EnvironmentObject private var viewModel: DailyLogViewModel
    @State private var showingLog = false

    var body: some View {
        SummaryCard(title: "Notes", systemImage: "note.text") {
            if log.notes.isEmpty {
                addButton { showingLog = true }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(log.notes) { note in
                        Text(note.content)
                            .font(.subheadline)
                            .lineLimit(2)
                    }
                }
                Button("Add more") { showingLog = true }
                    .font(.subheadline)
                    .foregroundStyle(.indigo)
                    .padding(.top, 2)
            }
        }
        .sheet(isPresented: $showingLog) {
            NoteLogView()
                .environmentObject(viewModel)
        }
    }
}

// MARK: - Shared helper

private func addButton(action: @escaping () -> Void) -> some View {
    Button(action: action) {
        Label("Add", systemImage: "plus.circle")
            .font(.subheadline)
            .foregroundStyle(.indigo)
    }
}

// MARK: - Preview

#Preview {
    let container = ModelContainer.preview
    return HomeView()
        .environmentObject(DailyLogViewModel.preview)
        .modelContainer(container)
}

