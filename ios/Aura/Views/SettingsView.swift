import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    @EnvironmentObject private var securityViewModel: SecurityViewModel
    @State private var notificationsAuthorised = false
    @State private var showingPermissionAlert  = false

    var body: some View {
        NavigationStack {
            Form {
                // MARK: Reminders
                Section {
                    reminderRow(
                        title:   "Preventive Medication",
                        icon:    "pill.fill",
                        enabled: $settingsViewModel.medicationReminderEnabled,
                        time:    $settingsViewModel.medicationReminderTime
                    )
                    reminderRow(
                        title:   "Morning Log (Sleep)",
                        icon:    "sunrise.fill",
                        enabled: $settingsViewModel.morningReminderEnabled,
                        time:    $settingsViewModel.morningReminderTime
                    )
                    reminderRow(
                        title:   "Evening Log",
                        icon:    "moon.fill",
                        enabled: $settingsViewModel.eveningReminderEnabled,
                        time:    $settingsViewModel.eveningReminderTime
                    )
                    reminderRow(
                        title:   "Bedtime",
                        icon:    "bed.double.fill",
                        enabled: $settingsViewModel.bedtimeReminderEnabled,
                        time:    $settingsViewModel.bedtimeReminderTime
                    )
                } header: {
                    Text("Reminders")
                } footer: {
                    Text("Reminders repeat daily at the selected time.")
                }

                // MARK: Security
                Section {
                    Toggle(isOn: $settingsViewModel.securityEnabled) {
                        Label("Require Face ID / Passcode", systemImage: "faceid")
                    }
                    .onChange(of: settingsViewModel.securityEnabled) { _, enabled in
                        // Sync to securityViewModel immediately
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
                    LabeledContent("Build",   value: buildNumber)
                }
            }
            .navigationTitle("Settings")
            .task {
                notificationsAuthorised = (try? await settingsViewModel.requestNotificationPermission()) ?? false
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
        title:   String,
        icon:    String,
        enabled: Binding<Bool>,
        time:    Binding<Date>
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

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "–"
    }
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "–"
    }
}
