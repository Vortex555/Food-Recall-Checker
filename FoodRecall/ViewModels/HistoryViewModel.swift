import Foundation
import SwiftData

@MainActor
@Observable
final class HistoryViewModel {
    var errorMessage: String?

    private let fdaService = FDARecallService()
    private let notificationManager = NotificationManager.shared

    func deleteItem(_ item: ScannedItem, context: ModelContext) {
        context.delete(item)
        try? context.save()
    }

    func toggleFavorite(_ item: ScannedItem, context: ModelContext) {
        item.isFavorite.toggle()
        try? context.save()
    }

    func toggleNotification(_ item: ScannedItem, context: ModelContext) async {
        if !item.notifyOnRecall {
            if !notificationManager.isAuthorized {
                let granted = await notificationManager.requestAuthorization()
                guard granted else { return }
            }
            item.notifyOnRecall = true
        } else {
            item.notifyOnRecall = false
        }
        try? context.save()
    }

    func recheckRecallStatus(for item: ScannedItem, context: ModelContext) async {
        let previousStatus = item.recallStatus
        do {
            let recalls = try await fdaService.checkProduct(name: item.productName, brand: item.brandName)
            item.recallStatus = recalls.isEmpty ? .clear : .recalled
            item.matchedRecallNumbers = recalls.map(\.recallNumber)
            item.lastCheckedDate = Date()
            try? context.save()

            if item.notifyOnRecall && item.recallStatus == .recalled && previousStatus != .recalled && !recalls.isEmpty {
                notificationManager.scheduleRecallNotification(
                    productName: item.productName,
                    recallCount: recalls.count
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func recheckAllFavorites(context: ModelContext) async {
        let descriptor = FetchDescriptor<ScannedItem>(
            predicate: #Predicate { $0.isFavorite }
        )
        guard let favorites = try? context.fetch(descriptor) else { return }

        for item in favorites {
            await recheckRecallStatus(for: item, context: context)
        }
    }
}
