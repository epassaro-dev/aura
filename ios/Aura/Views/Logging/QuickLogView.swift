import SwiftUI

/// One-tap entry point: a grid of category buttons that each open the relevant log sheet.
struct QuickLogView: View {
    @EnvironmentObject private var viewModel: DailyLogViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showStress    = false
    @State private var showSleep     = false
    @State private var showMigraine  = false
    @State private var showMedication = false
    @State private var showActivity  = false
    @State private var showFood      = false
    @State private var showNote      = false

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    categoryButton(
                        title: "Stress",
                        icon:  "brain.head.profile",
                        color: .purple
                    ) { showStress = true }

                    categoryButton(
                        title: "Sleep",
                        icon:  "moon.fill",
                        color: .indigo
                    ) { showSleep = true }

                    categoryButton(
                        title: "Migraine",
                        icon:  "bolt.fill",
                        color: .red
                    ) { showMigraine = true }

                    categoryButton(
                        title: "Medication",
                        icon:  "pill.fill",
                        color: .teal
                    ) { showMedication = true }

                    categoryButton(
                        title: "Activity",
                        icon:  "figure.run",
                        color: .green
                    ) { showActivity = true }

                    categoryButton(
                        title: "Food",
                        icon:  "fork.knife",
                        color: .orange
                    ) { showFood = true }

                    categoryButton(
                        title: "Note",
                        icon:  "note.text",
                        color: .blue
                    ) { showNote = true }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("What would you like to log?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .sheet(isPresented: $showStress)    { StressLogView().environmentObject(viewModel) }
        .sheet(isPresented: $showSleep)     { SleepLogView().environmentObject(viewModel) }
        .sheet(isPresented: $showMigraine)  { MigraineEpisodeLogView().environmentObject(viewModel) }
        .sheet(isPresented: $showMedication){ MedicationLogView().environmentObject(viewModel) }
        .sheet(isPresented: $showActivity)  { ActivityLogView().environmentObject(viewModel) }
        .sheet(isPresented: $showFood)      { FoodLogView().environmentObject(viewModel) }
        .sheet(isPresented: $showNote)      { NoteLogView().environmentObject(viewModel) }
    }

    private func categoryButton(
        title:  String,
        icon:   String,
        color:  Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 34))
                    .foregroundStyle(color)
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}
