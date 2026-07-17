import SwiftUI
import SwiftData

/// Preview sample-data scenarios. Attach one with
/// `#Preview(traits: .modifier(EmptyPreviewData()))` — the preview system
/// builds each scenario's container once, shares it across previews, and
/// reports container failures in the canvas, so no force-try is needed.
protocol SampleDataPreviewModifier: PreviewModifier where Context == ModelContainer {
    static func seed(context: ModelContext) throws
}

extension SampleDataPreviewModifier {
    static func makeSharedContext() throws -> ModelContainer {
        let container = try ModelContainer.makeAuraContainer(inMemory: true)
        let context = ModelContext(container)
        try seed(context: context)
        try context.save()
        return container
    }

    func body(content: Content, context: ModelContainer) -> some View {
        content.modelContainer(context)
    }
}

struct EmptyPreviewData: SampleDataPreviewModifier {
    static func seed(context: ModelContext) {}
}

/// One night of sleep logged today.
struct NightSleepPreviewData: SampleDataPreviewModifier {
    static func seed(context: ModelContext) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let start = calendar.date(byAdding: .hour, value: -8, to: .now) ?? .now
        context.insert(SleepEntry(date: today, type: .night, startTime: start, endTime: .now, quality: 4))
    }
}

/// A night of sleep plus an afternoon nap logged today.
struct FullSleepPreviewData: SampleDataPreviewModifier {
    static func seed(context: ModelContext) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let nightStart = calendar.date(byAdding: .hour, value: -9, to: .now) ?? .now
        let nightEnd = calendar.date(byAdding: .hour, value: -1, to: .now) ?? .now
        context.insert(SleepEntry(date: today, type: .night, startTime: nightStart, endTime: nightEnd, quality: 3))
        let napStart = calendar.date(byAdding: .minute, value: -45, to: .now) ?? .now
        context.insert(SleepEntry(date: today, type: .nap, startTime: napStart, endTime: .now, quality: 5))
    }
}

/// Three catalog medicines; Propranolol has an active 2×/day schedule with
/// one dose already taken today.
struct MedicationPreviewData: SampleDataPreviewModifier {
    static func seed(context: ModelContext) {
        let propranolol = Medicine(name: "Propranolol", sfSymbol: "pills.fill", defaultDosage: "40mg")
        let topiramate = Medicine(name: "Topiramate", sfSymbol: "pills.fill", defaultDosage: "25mg")
        let amitriptyline = Medicine(name: "Amitriptyline", sfSymbol: "pills.fill")
        [propranolol, topiramate, amitriptyline].forEach { context.insert($0) }
        context.insert(TreatmentSchedule(medicine: propranolol, timesPerDay: 2))
        let today = Calendar.current.startOfDay(for: .now)
        context.insert(MedicineLog(date: today, timestamp: .now, medicine: propranolol, dosage: "40mg"))
    }
}

/// A single 1×/day schedule with its dose already taken today.
struct CompletedMedicationPreviewData: SampleDataPreviewModifier {
    static func seed(context: ModelContext) {
        let medicine = Medicine(name: "Propranolol", sfSymbol: "pills.fill", defaultDosage: "40mg")
        context.insert(medicine)
        context.insert(TreatmentSchedule(medicine: medicine, timesPerDay: 1))
        let today = Calendar.current.startOfDay(for: .now)
        context.insert(MedicineLog(date: today, timestamp: .now, medicine: medicine, dosage: "40mg"))
    }
}

/// Bridges a shared sample container to previews of views that take a model
/// instance: fetches the first `Model` and passes it to `content`.
struct QueryPreview<Model: PersistentModel, Content: View>: View {
    @Query private var models: [Model]
    private let content: (Model) -> Content

    init(@ViewBuilder content: @escaping (Model) -> Content) {
        self.content = content
    }

    var body: some View {
        if let model = models.first {
            content(model)
        } else {
            ContentUnavailableView(
                "No \(String(describing: Model.self)) seeded",
                systemImage: "exclamationmark.triangle"
            )
        }
    }
}
