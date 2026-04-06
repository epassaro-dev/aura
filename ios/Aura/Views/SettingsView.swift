import SwiftUI
import SwiftData

struct SettingsView: View {
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    @EnvironmentObject private var securityViewModel: SecurityViewModel
    @Query(sort: \CustomSymptom.name) private var customSymptoms: [CustomSymptom]
    @Environment(\.modelContext) private var modelContext

    @State private var showingPermissionAlert = false
    @State private var newSymptomName = ""

    var body: some View {
        NavigationStack {
            Form {
                // MARK: Reminders
                Section {
                    reminderRow(
                        title: "Preventive Medication",
                        icon: "pill.fill",
                        enabled: $settingsViewModel.medicationReminderEnabled,
                        time: $settingsViewModel.medicationReminderTime
                    )
                    reminderRow(
                        title: "Morning Log (Sleep)",
                        icon: "sunrise.fill",
                        enabled: $settingsViewModel.morningReminderEnabled,
                        time: $settingsViewModel.morningReminderTime
                    )
                    reminderRow(
                        title: "Evening Log",
                        icon: "moon.fill",
                        enabled: $settingsViewModel.eveningReminderEnabled,
                        time: $settingsViewModel.eveningReminderTime
                    )
                    reminderRow(
                        title: "Bedtime",
                        icon: "bed.double.fill",
                        enabled: $settingsViewModel.bedtimeReminderEnabled,
                        time: $settingsViewModel.bedtimeReminderTime
                    )
                } header: {
                    Text("Reminders")
                } footer: {
                    Text("Reminders repeat daily at the selected time.")
                }

                // MARK: Custom Symptoms
                Section {
                    ForEach(customSymptoms) { symptom in
                        Text(symptom.name)
                    }
                    .onDelete { indices in
                        for index in indices {
                            modelContext.delete(customSymptoms[index])
                        }
                        try? modelContext.save()
                    }

                    HStack {
                        TextField("New symptom name…", text: $newSymptomName)
                            .autocorrectionDisabled()
                            .onSubmit { addCustomSymptom() }
                        Button(action: addCustomSymptom) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.indigo)
                        }
                        .disabled(newSymptomName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                } header: {
                    Text("Custom Symptoms")
                } footer: {
                    Text("Custom symptoms appear alongside built-in options when logging migraine and headache episodes.")
                }

                // MARK: Security
                Section {
                    Toggle(isOn: $settingsViewModel.securityEnabled) {
                        Label("Require Face ID / Passcode", systemImage: "faceid")
                    }
                    .onChange(of: settingsViewModel.securityEnabled) { _, enabled in
                        if !enabled { securityViewModel.isLocked = false }
                    }
                } header: {
                    Text("Security")
                } footer: {
                    Text("When enabled, the app locks whenever it moves to the background.")
                }

                // MARK: About
                Section("About") {
                    LabeledContent("Version", value: appVersion)
                    LabeledContent("Build", value: buildNumber)
                }
            }
            .navigationTitle("Settings")
            .task {
                let granted = await settingsViewModel.requestNotificationPermission()
                if !granted { showingPermissionAlert = true }
            }
            .alert("Notifications Disabled", isPresented: $showingPermissionAlert) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please enable notifications in iOS Settings to receive reminders.")
            }
        }
    }

    // MARK: - Row helper

    @ViewBuilder
    private func reminderRow(
        title: String,
        icon: String,
        enabled: Binding<Bool>,
        time: Binding<Date>
    ) -> some View {
        VStack(spacing: 0) {
            Toggle(isOn: enabled) {
                Label(title, systemImage: icon)
            }
            if enabled.wrappedValue {
                DatePicker(
                    "Time",
                    selection: time,
                    displayedComponents: .hourAndMinute
                )
                .transition(.opacity)
            }
        }
    }

    // MARK: - Helpers

    private func addCustomSymptom() {
        let name = newSymptomName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        let symptom = CustomSymptom(name: name)
        modelContext.insert(symptom)
        try? modelContext.save()
        newSymptomName = ""
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "–"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "–"
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
        .environmentObject(SettingsViewModel())
        .environmentObject(SecurityViewModel())
        .modelContainer(ModelContainer.preview)
}

