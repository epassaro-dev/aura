import SwiftUI
import SwiftData

struct TreatmentPlanManagementSheet: View {
    @Environment(\.dismiss) private var dismiss

    private enum ActiveSheet: Identifiable {
        case catalog
        case planForm(mode: TreatmentPlanSheetMode)

        var id: String {
            switch self {
            case .catalog: "catalog"
            case .planForm: "planForm"
            }
        }
    }

    @Query(filter: #Predicate<TreatmentPlan> { $0.endDate == nil })
    private var plans: [TreatmentPlan]

    @State private var activeSheet: ActiveSheet?

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(plans) { plan in
                        HStack {
                            Image(systemName: plan.medicine.sfSymbol)
                                .font(.title2)
                                .foregroundStyle(.tint)
                                .frame(width: 32)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(plan.medicine.name) \(plan.dosageString())")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(plan.scheduleString())
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button {
                                activeSheet = .planForm(mode: .edit(plan))
                            } label: {
                                Image(systemName: "pencil")
                            }
                            .imageScale(.large)
                            .accessibilityLabel("Edit plan")
                        }
                    }
                    Button {
                        activeSheet = .catalog
                    } label: {
                        Label("Add treatment plan", systemImage: "plus.circle")
                    }
                }
            }
            .navigationTitle("Treatment Plans")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done", role: .cancel) { dismiss() }
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .catalog:
                MedicineCatalogSheet { medicine in
                    activeSheet = .planForm(mode: .create(medicine))
                }
            case .planForm(let mode):
                TreatmentPlanSheet(mode: mode)
            }
        }
    }
}

#Preview("Empty", traits: .modifier(MedicinePreviewData())) {
    TreatmentPlanManagementSheet()
}

#Preview("Existing plans", traits: .modifier(TreatmentPlanPreviewData())) {
    TreatmentPlanManagementSheet()
}
