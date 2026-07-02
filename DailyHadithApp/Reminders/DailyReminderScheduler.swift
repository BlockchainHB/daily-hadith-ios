import Foundation
import UserNotifications

enum DailyReminderSlot: String, CaseIterable, Identifiable {
    case morning
    case afternoon
    case evening

    var id: String { rawValue }

    var title: String {
        switch self {
        case .morning: "Morning"
        case .afternoon: "Afternoon"
        case .evening: "Evening"
        }
    }

    var defaultHour: Int {
        switch self {
        case .morning: 8
        case .afternoon: 13
        case .evening: 20
        }
    }
}

struct DailyReminderTime: Equatable {
    var hour: Int
    var minute: Int

    static let morning = DailyReminderTime(hour: DailyReminderSlot.morning.defaultHour, minute: 0)

    var dateComponents: DateComponents {
        DateComponents(hour: hour, minute: minute)
    }

    var displayText: String {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        guard let date = Calendar.current.date(from: components) else {
            return "8:00 AM"
        }

        return Self.formatter.string(from: date)
    }

    static func from(_ date: Date) -> DailyReminderTime {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        return DailyReminderTime(hour: components.hour ?? 8, minute: components.minute ?? 0)
    }

    func asDate() -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? Date()
    }

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()
}

enum DailyReminderScheduler {
    static let requestIdentifier = "daily-hadith.reminder"

    static func scheduleDailyReminder(at time: DailyReminderTime) async -> Bool {
        let center = UNUserNotificationCenter.current()

        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            guard granted else {
                center.removePendingNotificationRequests(withIdentifiers: [requestIdentifier])
                return false
            }

            let content = UNMutableNotificationContent()
            content.title = "Daily Hadith"
            content.body = "A quiet moment to listen and reflect."
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: time.dateComponents,
                repeats: true
            )
            let request = UNNotificationRequest(
                identifier: requestIdentifier,
                content: content,
                trigger: trigger
            )

            center.removePendingNotificationRequests(withIdentifiers: [requestIdentifier])
            try await center.add(request)
            return true
        } catch {
            center.removePendingNotificationRequests(withIdentifiers: [requestIdentifier])
            return false
        }
    }

    static func cancelDailyReminder() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [requestIdentifier])
    }
}
