import Foundation
import UserNotifications

final class NotificationScheduler {
    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                continuation.resume(returning: granted)
            }
        }
    }

    func scheduleDailyReminders(times: [Date], language: AppLanguage) async throws {
        center.removeAllPendingNotificationRequests()

        let calendar = Calendar.current
        for (index, date) in times.sorted().enumerated() {
            let timeComponents = calendar.dateComponents([.hour, .minute], from: date)

            let content = UNMutableNotificationContent()
            switch language {
            case .vi:
                content.title = "Nhớ hành động nhỏ"
                content.body = "Check-in hôm nay để giữ nhịp tiến bộ của bạn."
            case .en:
                content.title = "Tiny action reminder"
                content.body = "Check in today to keep your momentum alive."
            }
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: DateComponents(hour: timeComponents.hour, minute: timeComponents.minute),
                repeats: true
            )

            let request = UNNotificationRequest(
                identifier: "daily_reminder_\(index)",
                content: content,
                trigger: trigger
            )

            try await center.add(request)
        }
    }
}
