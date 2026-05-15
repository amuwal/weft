import Foundation
import UIKit
import UserNotifications

@MainActor
enum NudgeScheduler {
    private static let requestID = "weft.daily-nudge"

    /// Asks for permission, then schedules / clears based on `enabled`.
    static func sync(enabled: Bool, hour: Int) async {
        let center = UNUserNotificationCenter.current()
        guard enabled else {
            center.removePendingNotificationRequests(withIdentifiers: [requestID])
            return
        }

        let granted = await requestPermissionIfNeeded()
        guard granted else { return }

        center.removePendingNotificationRequests(withIdentifiers: [requestID])

        let content = UNMutableNotificationContent()
        content.title = "Who's on your mind?"
        content.body = "A quiet moment to think about your people."
        content.sound = nil

        var components = DateComponents()
        components.hour = hour
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(identifier: requestID, content: content, trigger: trigger)
        try? await center.add(request)
    }

    private static func requestPermissionIfNeeded() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        case .notDetermined:
            return await (try? center.requestAuthorization(options: [.alert, .badge])) ?? false
        @unknown default:
            return false
        }
    }
}
