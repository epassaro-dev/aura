import SwiftUI
import SwiftData

struct MedicationSectionView: View {
    private let context: ModelContext
    @State private var viewModel: MedicationSectionViewModel

    init(context: ModelContext) {
        self.context = context
        _viewModel = State(wrappedValue: MedicationSectionViewModel(context: context))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Medications")
                .font(.headline)
            if viewModel.schedules.isEmpty {
                Button("Set up treatment plan") {
                    viewModel.showCatalog = true
                }
                .buttonStyle(.borderedProminent)
            } else {
                ForEach(viewModel.schedules) { schedule in
                    scheduleRow(schedule: schedule, vm: viewModel)
                }
            }
        }
        .sheet(isPresented: $viewModel.showCatalog) {
            MedicineCatalogSheet(context: context) {
                viewModel.showCatalog = false
                viewModel.fetch()
            }
        }
    }

    @ViewBuilder
    private func scheduleRow(schedule: TreatmentSchedule, vm: MedicationSectionViewModel) -> some View {
        HStack(spacing: 12) {
            Image(systemName: schedule.medicine?.sfSymbol ?? "pills.fill")
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(schedule.medicine?.name ?? "Unknown")
                    .font(.subheadline)
                    .fontWeight(.medium)
                let taken = vm.takenCount(for: schedule)
                Text("\(taken) of \(schedule.timesPerDay) taken today")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if vm.isCompleted(for: schedule) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.title2)
            } else {
                Button("Take") {
                    vm.markTaken(for: schedule)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview("Empty state") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Medicine.self, configurations: config)
    return MedicationSectionView(context: container.mainContext)
        .modelContainer(container)
        .padding()
}

#Preview("Partially taken") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Medicine.self, configurations: config)
    let medicine = Medicine(name: "Propranolol", sfSymbol: "pills.fill", defaultDosage: "40mg")
    let schedule = TreatmentSchedule(medicine: medicine, timesPerDay: 2)
    container.mainContext.insert(medicine)
    container.mainContext.insert(schedule)
    return MedicationSectionView(context: container.mainContext)
        .modelContainer(container)
        .padding()
}

#Preview("All doses taken") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Medicine.self, configurations: config)
    let medicine = Medicine(name: "Propranolol", sfSymbol: "pills.fill", defaultDosage: "40mg")
    let schedule = TreatmentSchedule(medicine: medicine, timesPerDay: 1)
    let today = Calendar.current.startOfDay(for: .now)
    let log = MedicineLog(date: today, timestamp: .now, medicine: medicine, dosage: "40mg")
    container.mainContext.insert(medicine)
    container.mainContext.insert(schedule)
    container.mainContext.insert(log)
    return MedicationSectionView(context: container.mainContext)
        .modelContainer(container)
        .padding()
}
