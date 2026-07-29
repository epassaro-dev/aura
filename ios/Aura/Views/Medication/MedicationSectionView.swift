import SwiftUI
import SwiftData
import OSLog

struct MedicationSectionView: View {
    @Environment(\.modelContext) private var context

    @Query(filter: #Predicate<TreatmentSchedule> { $0.endDate == nil })
    private var schedules: [TreatmentSchedule]
    @Query private var todayLogs: [MedicineLog]

    @State private var showCatalog = false
    @State private var editingSchedule: TreatmentSchedule?

    private var progress: MedicationProgress {
        MedicationProgress(schedules: schedules, logs: todayLogs)
    }

    init(day: Date, nextDay: Date) {
        _todayLogs = Query(filter: #Predicate<MedicineLog> { log in
            log.date >= day && log.date < nextDay
        })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Medications")
                .font(.headline)
            if schedules.isEmpty {
                Button("Set up treatment plan") {
                    showCatalog = true
                }
                .buttonStyle(.borderedProminent)
            } else {
                ForEach(schedules) { schedule in
                    scheduleRow(schedule: schedule)
                }
            }
        }
        .sheet(isPresented: $showCatalog) {
            MedicineCatalogSheet()
        }
        .sheet(item: $editingSchedule) { schedule in
            TreatmentScheduleSheet(mode: .edit(schedule)) { }
        }
    }

    @ViewBuilder
    private func scheduleRow(schedule: TreatmentSchedule) -> some View {
        HStack(spacing: 12) {
            Image(systemName: schedule.medicine.sfSymbol)
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                let dosageString = schedule.dosage?.asString() ?? schedule.medicine.defaultDosage?.asString() ?? ""
                Text("\(schedule.medicine.name) \(dosageString)")
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
        .contextMenu {
            Button {
                editingSchedule = schedule
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            Button(role: .destructive) {
                stopTreatment(schedule)
            } label: {
                Label("Stop treatment", systemImage: "trash")
            }
        }
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

    private func stopTreatment(_ schedule: TreatmentSchedule) {
        schedule.stop()
        do {
            try context.save()
        } catch {
            Logger.persistence.error("Failed to stop treatment: \(String(describing: error), privacy: .public)")
            context.rollback()
        }
    }
}

#Preview("Empty state", traits: .modifier(MedicinePreviewData())) {
    let today = Calendar.current.startOfDay(for: .now)
    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
    MedicationSectionView(day: today, nextDay: tomorrow)
        .padding()
}

#Preview("Partially taken", traits: .modifier(TreatmentSchedulePreviewData())) {
    let today = Calendar.current.startOfDay(for: .now)
    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
    MedicationSectionView(day: today, nextDay: tomorrow)
        .padding()
}

#Preview("All doses taken", traits: .modifier(CompletedDailyTreatmentPreviewData())) {
    let today = Calendar.current.startOfDay(for: .now)
    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
    MedicationSectionView(day: today, nextDay: tomorrow)
        .padding()
}
