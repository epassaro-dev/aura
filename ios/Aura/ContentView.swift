import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                MedicationSectionView(context: context)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Medicine.self, inMemory: true)
}
