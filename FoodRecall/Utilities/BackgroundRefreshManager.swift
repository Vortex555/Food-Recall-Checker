import BackgroundTasks
import SwiftData

struct BackgroundRefreshManager {
    static let taskIdentifier = "com.foodrecall.iosapp.recallcheck"

    static func registerTask(modelContainer: ModelContainer) {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
            guard let task = task as? BGAppRefreshTask else { return }
            handleRefresh(task: task, modelContainer: modelContainer)
        }
    }

    static func scheduleNextRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 4 * 60 * 60) // 4 hours
        try? BGTaskScheduler.shared.submit(request)
    }

    private static func handleRefresh(task: BGAppRefreshTask, modelContainer: ModelContainer) {
        scheduleNextRefresh()

        nonisolated(unsafe) let bgTask = task
        let workTask = Task { @MainActor in
            await checkNotifiedItems(modelContainer: modelContainer)
            bgTask.setTaskCompleted(success: true)
        }

        task.expirationHandler = {
            workTask.cancel()
        }
    }

    @MainActor
    private static func checkNotifiedItems(modelContainer: ModelContainer) async {
        let context = ModelContext(modelContainer)
        let fdaService = FDARecallService()

        let descriptor = FetchDescriptor<ScannedItem>(
            predicate: #Predicate { $0.notifyOnRecall }
        )
        guard let items = try? context.fetch(descriptor), !items.isEmpty else { return }

        for item in items {
            let previousStatus = item.recallStatus
            let previousRecallNumbers = item.matchedRecallNumbers

            do {
                let recalls = try await fdaService.checkProduct(name: item.productName, brand: item.brandName)
                item.recallStatus = recalls.isEmpty ? .clear : .recalled
                item.matchedRecallNumbers = recalls.map(\.recallNumber)
                item.lastCheckedDate = Date()

                let newRecallNumbers = Set(item.matchedRecallNumbers).subtracting(Set(previousRecallNumbers))
                let statusChangedToRecalled = item.recallStatus == .recalled && previousStatus != .recalled
                let hasNewRecalls = !newRecallNumbers.isEmpty && item.recallStatus == .recalled

                if statusChangedToRecalled || hasNewRecalls {
                    NotificationManager.shared.scheduleRecallNotification(
                        productName: item.productName,
                        recallCount: statusChangedToRecalled ? recalls.count : newRecallNumbers.count
                    )
                }
            } catch {
                // Skip this item on failure
            }
        }
        try? context.save()
    }
}
