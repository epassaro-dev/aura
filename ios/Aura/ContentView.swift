import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var today = Calendar.current.startOfDay(for: .now)

    private var tomorrow: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                SleepSectionView(day: today, nextDay: tomorrow)
                MedicationSectionView(day: today, nextDay: tomorrow)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged).receive(on: RunLoop.main)) { _ in
            refreshToday()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                refreshToday()
            }
        }
    }

    private func refreshToday() {
        today = Calendar.current.startOfDay(for: .now)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SleepEntry.self, Medicine.self, configurations: config)
    return ContentView()
        .modelContainer(container)
}
