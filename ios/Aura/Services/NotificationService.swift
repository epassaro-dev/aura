import UserNotifications
import Foundation

/// Thread-safe actor that schedules and cancels daily local notifications.
actor NotificationService {
    static let shared = NotificationService()

    private init() {}

    // MARK: - Permission

    func requestAuthorization() async throws -> Bool {
        try await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge])
    }

    // MARK: - Update all reminders

    /// Replaces all four Aura reminders with the supplied times.
    /// Pass `nil` for a reminder type to cancel it.
    func updateReminders(
        medication: Date?,
        morning:    Date?,
        evening:    Date?,
        bedtime:    Date?
    ) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(
            withIdentifiers: Identifier.all
        )

        let pairs: [(Date?, String, String, String)] = [
            (medication, Identifier.medication, "Medication Reminder",
             "Time to take your preventive medication."),
            (morning,    Identifier.morning,    "Good Morning!",
             "Don't forget to log last night's sleep in Aura."),
            (evening,    Identifier.evening,    "Evening Check-in",
             "How was your day? Log stress, food and activities in Aura."),
            (bedtime,    Identifier.bedtime,    "Bedtime",
             "Time to wind down. Sweet dreams! 🌙"),
        ]

        for (date, id, title, body) in pairs {
            if let date {
                scheduleDaily(identifier: id, title: title, body: body, at: date)
            }
        }
    }

    // MARK: - Private

    private func scheduleDaily(
        identifier: String,
        title:      String,
        body:       String,
        at date:    Date
    ) {
        let content       = UNMutableNotificationContent()
        content.title     = title
        content.body      = body
        content.sound     = .default

        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let trigger    = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(
            identifier: identifier,
            content:    content,
            trigger:    trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Identifiers

    private enum Identifier {
        static let medication = "com.aura.reminder.medication"
        static let morning    = "com.aura.reminder.morning"
        static let evening    = "com.aura.reminder.evening"
        static let bedtime    = "com.aura.reminder.bedtime"
        static let all        = [medication, morning, evening, bedtime]
    }
}
