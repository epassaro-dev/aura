import SwiftUI
import SwiftData
import OSLog

struct MedicationSectionView: View {
    @Environment(\.modelContext) private var context
    @Query(filter: #Predicate<TreatmentSchedule> { $0.isActive == true })
    private var schedules: [TreatmentSchedule]
    @Query private var todayLogs: [MedicineLog]
    @State private var showCatalog = false

    init(day: Date, nextDay: Date) {
        _todayLogs = Query(filter: #Predicate<MedicineLog> { log in
            log.date >= day && log.date < nextDay
        })
    }

    private var progress: MedicationProgress {
        MedicationProgress(schedules: schedules, logs: todayLogs)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Medications")
                .font(.headline)
            let displaySchedules = progress.displaySchedules
            if displaySchedules.isEmpty {
                Button("Set up treatment plan") {
                    showCatalog = true
                }
                .buttonStyle(.borderedProminent)
            } else {
                ForEach(displaySchedules) { schedule in
                    scheduleRow(schedule: schedule)
                }
            }
        }
        .sheet(isPresented: $showCatalog) {
            MedicineCatalogSheet()
        }
    }

    @ViewBuilder
    private func scheduleRow(schedule: TreatmentSchedule) -> some View {
        HStack(spacing: 12) {
            Image(systemName: schedule.medicine?.sfSymbol ?? "pills.fill")
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(schedule.medicine?.name ?? "Unknown")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("\(progress.takenCount(for: schedule)) of \(schedule.timesPerDay) taken today")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if progress.isCompleted(for: schedule) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.title2)
            } else {
                Button("Take") {
                    recordDose(for: schedule)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.vertical, 4)
    }

    private func recordDose(for schedule: TreatmentSchedule) {
        guard let log = TreatmentPlanner.doseLog(for: schedule, progress: progress) else { return }
        context.insert(log)
        do {
            try context.save()
        } catch {
            Logger.persistence.error("Failed to record dose: \(String(describing: error), privacy: .public)")
        }
    }
}

#Preview("Empty state", traits: .modifier(EmptyPreviewData())) {
    let today = Calendar.current.startOfDay(for: .now)
    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
    MedicationSectionView(day: today, nextDay: tomorrow)
        .padding()
}

#Preview("Partially taken", traits: .modifier(MedicationPreviewData())) {
    let today = Calendar.current.startOfDay(for: .now)
    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
    MedicationSectionView(day: today, nextDay: tomorrow)
        .padding()
}

#Preview("All doses taken", traits: .modifier(CompletedMedicationPreviewData())) {
    let today = Calendar.current.startOfDay(for: .now)
    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
    MedicationSectionView(day: today, nextDay: tomorrow)
        .padding()
}
