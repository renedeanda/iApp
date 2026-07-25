// SOURCE: proven in a shipped production app.
// Simple, opt-in UserNotifications wrapper.

import Foundation
import UserNotifications

/// Local + remote notifications via UNUserNotifications.
///
/// **Graduate** when DECISIONS/004-native-feature-checklist.md enables
/// notifications. Wizard also uncomments `aps-environment` in
/// `Sprout.entitlements` if remote pushes are needed.
///
/// Source pattern: clean opt-in flow proven in a shipped production
/// app. For RN apps the equivalent gold-standard is the RN template's
/// notification service (rolling 64-limit window).
///
/// Per docs/NOT_FOR.md §3 + §11:
/// - No engagement-maximizing notifications; only user-scheduled.
/// - No re-engagement pings or "we miss you" pushes.
@MainActor
final class NotificationService {
    static let shared = NotificationService()

    private let center = UNUserNotificationCenter.current()

    private init() {}

    /// Request authorization. Returns true if granted (provisional or full).
    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    /// Schedule a one-shot local notification.
    func schedule(
        id: String,
        title: String,
        body: String,
        at date: Date
    ) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let interval = date.timeIntervalSinceNow
        guard interval > 0 else { return }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        try? await center.add(request)
    }

    /// Cancel a scheduled notification by id.
    func cancel(id: String) {
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }

    /// Cancel everything pending.
    func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }
}
