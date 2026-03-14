import UserNotifications

@MainActor
@Observable
final class NotificationManager {
    static let shared = NotificationManager()

    var isAuthorized = false

    private init() {}

    func checkAuthorization() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
            return granted
        } catch {
            return false
        }
    }

    func scheduleRecallNotification(productName: String, recallCount: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Recall Alert"
        content.body = "\(productName) has \(recallCount) new recall\(recallCount == 1 ? "" : "s"). Open the app to review."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "recall-\(productName)-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }
}
