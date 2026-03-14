import Foundation
import SwiftData

enum RecallStatus: String, Codable, Sendable {
    case clear
    case recalled
    case unknown
}

@Model
final class ScannedItem {
    @Attribute(.unique) var barcode: String
    var productName: String
    var brandName: String
    var imageURL: String?
    var scanDate: Date
    var recallStatus: RecallStatus
    var matchedRecallNumbers: [String]
    var lastCheckedDate: Date
    var isFavorite: Bool
    var notifyOnRecall: Bool

    init(
        barcode: String,
        productName: String,
        brandName: String,
        imageURL: String? = nil,
        recallStatus: RecallStatus,
        matchedRecallNumbers: [String] = []
    ) {
        self.barcode = barcode
        self.productName = productName
        self.brandName = brandName
        self.imageURL = imageURL
        self.scanDate = Date()
        self.recallStatus = recallStatus
        self.matchedRecallNumbers = matchedRecallNumbers
        self.lastCheckedDate = Date()
        self.isFavorite = false
        self.notifyOnRecall = false
    }
}
