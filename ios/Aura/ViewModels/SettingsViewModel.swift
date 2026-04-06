import Foundation
import Combine

/// Persists user preferences for reminders and security to `UserDefaults`
/// and keeps local notifications in sync via `NotificationService`.
@MainActor
final class SettingsViewModel: ObservableObject {

    // MARK: - Reminder toggles & times

    @Published var medicationReminderEnabled: Bool
    @Published var medicationReminderTime: Date

    @Published var morningReminderEnabled: Bool
    @Published var morningReminderTime: Date

    @Published var eveningReminderEnabled: Bool
    @Published var eveningReminderTime: Date

    @Published var bedtimeReminderEnabled: Bool
    @Published var bedtimeReminderTime: Date

    // MARK: - Security

    @Published var securityEnabled: Bool

    // MARK: - Private

    private let notificationService: NotificationService
    private let defaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Keys

    private enum Key {
        static let medicationEnabled = "medicationReminderEnabled"
        static let medicationTime = "medicationReminderTime"
        static let morningEnabled = "morningReminderEnabled"
        static let morningTime = "morningReminderTime"
        static let eveningEnabled = "eveningReminderEnabled"
        static let eveningTime = "eveningReminderTime"
        static let bedtimeEnabled = "bedtimeReminderEnabled"
        static let bedtimeTime = "bedtimeReminderTime"
        static let securityEnabled = "securityEnabled"
    }

    // MARK: - Init

    init(notificationService: NotificationService = .shared) {
        self.notificationService = notificationService

        func date(_ h: Int, _ m: Int) -> Date {
            Calendar.current.date(bySettingHour: h, minute: m, second: 0, of: .now) ?? .now
        }
        let d = UserDefaults.standard

        medicationReminderEnabled = d.bool(forKey: Key.medicationEnabled)
        medicationReminderTime = (d.object(forKey: Key.medicationTime) as? Date) ?? date(8, 0)
        morningReminderEnabled = d.bool(forKey: Key.morningEnabled)
        morningReminderTime = (d.object(forKey: Key.morningTime) as? Date) ?? date(7, 30)
        eveningReminderEnabled = d.bool(forKey: Key.eveningEnabled)
        eveningReminderTime = (d.object(forKey: Key.eveningTime) as? Date) ?? date(20, 0)
        bedtimeReminderEnabled = d.bool(forKey: Key.bedtimeEnabled)
        bedtimeReminderTime = (d.object(forKey: Key.bedtimeTime) as? Date) ?? date(22, 30)
        securityEnabled = d.bool(forKey: Key.securityEnabled)

        setupObservers()
    }

    // MARK: - Observers

    private func setupObservers() {
        let reminderPublishers = Publishers.MergeMany(
            $medicationReminderEnabled.map { _ in () }.eraseToAnyPublisher(),
            $medicationReminderTime.map { _ in () }.eraseToAnyPublisher(),
            $morningReminderEnabled.map { _ in () }.eraseToAnyPublisher(),
            $morningReminderTime.map { _ in () }.eraseToAnyPublisher(),
            $eveningReminderEnabled.map { _ in () }.eraseToAnyPublisher(),
            $eveningReminderTime.map { _ in () }.eraseToAnyPublisher(),
            $bedtimeReminderEnabled.map { _ in () }.eraseToAnyPublisher(),
            $bedtimeReminderTime.map { _ in () }.eraseToAnyPublisher()
        )

        reminderPublishers
            .dropFirst()
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in self?.persistAndUpdateNotifications() }
            .store(in: &cancellables)

        $securityEnabled
            .dropFirst()
            .sink { [weak self] value in
                self?.defaults.set(value, forKey: Key.securityEnabled)
            }
            .store(in: &cancellables)
    }

    // MARK: - Persist + Notify

    private func persistAndUpdateNotifications() {
        defaults.set(medicationReminderEnabled, forKey: Key.medicationEnabled)
        defaults.set(medicationReminderTime, forKey: Key.medicationTime)
        defaults.set(morningReminderEnabled, forKey: Key.morningEnabled)
        defaults.set(morningReminderTime, forKey: Key.morningTime)
        defaults.set(eveningReminderEnabled, forKey: Key.eveningEnabled)
        defaults.set(eveningReminderTime, forKey: Key.eveningTime)
        defaults.set(bedtimeReminderEnabled, forKey: Key.bedtimeEnabled)
        defaults.set(bedtimeReminderTime, forKey: Key.bedtimeTime)

        Task {
            await notificationService.updateReminders(
                medication: medicationReminderEnabled ? medicationReminderTime : nil,
                morning: morningReminderEnabled ? morningReminderTime : nil,
                evening: eveningReminderEnabled ? eveningReminderTime : nil,
                bedtime: bedtimeReminderEnabled ? bedtimeReminderTime : nil
            )
        }
    }

    // MARK: - Public helpers

    func requestNotificationPermission() async -> Bool {
        (try? await notificationService.requestAuthorization()) ?? false
    }
}

