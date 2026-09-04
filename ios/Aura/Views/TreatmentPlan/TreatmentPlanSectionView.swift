import SwiftUI
import SwiftData
import OSLog

struct TreatmentPlanSectionView: View {
    @Environment(\.modelContext) private var context

    @Query(filter: #Predicate<TreatmentPlan> { $0.endDate == nil })
    private var plans: [TreatmentPlan]
    @Query private var todayLogs: [MedicineLog]

    @State private var showCatalog = false
    @State private var editingPlan: TreatmentPlan?

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
            Text("Medications")
                .font(.headline)
            if plans.isEmpty {
                Button("Set up treatment plan") {
                    showCatalog = true
                }
                .buttonStyle(.borderedProminent)
            } else {
                ForEach(plans) { plan in
                    planRow(plan: plan)
                }
            }
        }
        .sheet(isPresented: $showCatalog) {
            MedicineCatalogSheet()
        }
        .sheet(item: $editingPlan) { plan in
            TreatmentPlanSheet(mode: .edit(plan)) { }
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
                let dosageString = plan.dosage?.asString() ?? plan.medicine.defaultDosage?.asString() ?? ""
                Text("\(plan.medicine.name) \(dosageString)")
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
        .contextMenu {
            Button {
                editingPlan = plan
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            Button(role: .destructive) {
                stopTreatment(plan)
            } label: {
                Label("Stop treatment", systemImage: "trash")
            }
        }
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

    private func stopTreatment(_ plan: TreatmentPlan) {
        plan.stop()
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
