import Foundation
import UserNotifications

enum NotificationScheduler {
    static func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    static func schedule(task: TimelineTask, leadDays: Int = 3) async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized else { return }

        let triggerDate = Calendar.current.date(
            byAdding: .day, value: -leadDays, to: task.deadlineDate
        ) ?? task.deadlineDate

        let content = UNMutableNotificationContent()
        content.title = "\(task.countryFlag) \(task.title)"
        content.body = "Deadline: \(task.dateOffsetLabel). Don't forget to upload proof."
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)
        try? await center.add(request)
    }

    static func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
