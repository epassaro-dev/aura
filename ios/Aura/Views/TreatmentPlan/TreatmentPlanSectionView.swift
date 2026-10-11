import SwiftUI
import SwiftData
import OSLog

struct TreatmentPlanSectionView: View {
    @Environment(\.modelContext) private var context

    @Query(filter: #Predicate<TreatmentPlan> { $0.endDate == nil })
    private var plans: [TreatmentPlan]
    @Query private var todayLogs: [MedicineLog]

    @State private var showPlanManagement = false

    private var progress: MedicationProgress {
        MedicationProgress(plans: plans, logs: todayLogs)
    }

    init(day: Date, nextDay: Date) {
        _todayLogs = Query(filter: #Predicate<MedicineLog> { log in
            log.date >= day && log.date < nextDay
        })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Medications")
                    .font(.headline)
                if !plans.isEmpty {
                    Spacer()
                    Button {
                        showPlanManagement = true
                    } label: {
                        Label("Edit Plans", systemImage: "pencil")
                    }
                }
            }
            if plans.isEmpty {
                Button("Set up treatment plan") {
                    showPlanManagement = true
                }
                .buttonStyle(.borderedProminent)
            } else {
                ForEach(plans) { plan in
                    planRow(plan: plan)
                }
            }
        }
        .sheet(isPresented: $showPlanManagement) {
            TreatmentPlanManagementSheet()
        }
    }

    @ViewBuilder
    private func planRow(plan: TreatmentPlan) -> some View {
        HStack(spacing: 12) {
            Image(systemName: plan.medicine.sfSymbol)
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(plan.medicine.name) \(plan.dosageString())")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("\(progress.takenCount(for: plan)) of \(plan.timesPerDay) taken today")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if progress.isCompleted(for: plan) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.title2)
            } else {
                Button("Take") {
                    recordDose(for: plan)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.vertical, 4)
    }

    private func recordDose(for plan: TreatmentPlan) {
        guard let log = TreatmentPlanner.doseLog(for: plan, progress: progress) else { return }
        context.insert(log)
        do {
            try context.save()
        } catch {
            Logger.persistence.error("Failed to record dose: \(String(describing: error), privacy: .public)")
        }
    }
}

#Preview("Empty state", traits: .modifier(MedicinePreviewData())) {
    let today = Calendar.current.startOfDay(for: .now)
    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
    TreatmentPlanSectionView(day: today, nextDay: tomorrow)
        .padding()
}

#Preview("Partially taken", traits: .modifier(TreatmentPlanPreviewData())) {
    let today = Calendar.current.startOfDay(for: .now)
    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
    TreatmentPlanSectionView(day: today, nextDay: tomorrow)
        .padding()
}

#Preview("All doses taken", traits: .modifier(CompletedDailyTreatmentPreviewData())) {
    let today = Calendar.current.startOfDay(for: .now)
    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
    TreatmentPlanSectionView(day: today, nextDay: tomorrow)
        .padding()
}
