import SwiftUI
import SwiftData

struct FoodLogView: View {
    @EnvironmentObject private var viewModel: DailyLogViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var mealType: MealType = .breakfast
    @State private var newItem: String = ""
    @State private var items: [String] = []
    @State private var eatenAt: Date = .now
    @State private var notes: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Meal") {
                    Picker("Meal Type", selection: $mealType) {
                        ForEach(MealType.allCases, id: \.self) { m in
                            Label(m.rawValue, systemImage: m.systemImage).tag(m)
                        }
                    }
                    .pickerStyle(.menu)

                    DatePicker("Eaten at", selection: $eatenAt, displayedComponents: [.hourAndMinute])
                }

                Section {
                    ForEach(items, id: \.self) { item in
                        Text(item)
                    }
                    .onDelete { indices in items.remove(atOffsets: indices) }

                    HStack {
                        TextField("Add food item…", text: $newItem)
                            .autocorrectionDisabled()
                            .onSubmit { addItem() }
                        Button(action: addItem) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.indigo)
                        }
                        .disabled(newItem.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                } header: {
                    Text("Food Items")
                } footer: {
                    Text("Press return or + to add each item.")
                }

                Section("Notes (optional)") {
                    TextField("Any observations…", text: $notes, axis: .vertical)
                        .lineLimit(3...)
                }
            }
            .navigationTitle("Log Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
        }
    }

    private func addItem() {
        let trimmed = newItem.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        items.append(trimmed)
        newItem = ""
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("Save") {
                let entry = FoodEntry(
                    mealType: mealType,
                    items: items,
                    eatenAt: eatenAt,
                    notes: notes
                )
                viewModel.addFoodEntry(entry)
                dismiss()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    FoodLogView()
        .environmentObject(DailyLogViewModel.preview)
        .modelContainer(ModelContainer.preview)
}

