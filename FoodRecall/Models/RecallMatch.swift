import Foundation

struct RecallMatch: Identifiable, Sendable {
    let id = UUID()
    let product: OFFProduct?
    let recalls: [FDARecall]
    let status: RecallStatus
    let barcode: String?
}
