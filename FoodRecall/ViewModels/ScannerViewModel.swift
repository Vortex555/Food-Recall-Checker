import Foundation
import SwiftData

@MainActor
@Observable
final class ScannerViewModel {
    var isScanning = true
    var isLoading = false
    var result: RecallMatch?
    var errorMessage: String?
    var showResult = false
    var manualProductName = ""

    private let offService = OpenFoodFactsService()
    private let fdaService = FDARecallService()

    func handleBarcode(_ barcode: String, context: ModelContext) async {
        guard !isLoading else { return }
        isScanning = false
        isLoading = true
        errorMessage = nil

        do {
            let product = try await offService.lookupBarcodeWithFallback(barcode)
            let recalls = try await checkRecalls(for: product)
            let filteredRecalls = filterRelevantRecalls(recalls, product: product)
            let status: RecallStatus = filteredRecalls.isEmpty ? .clear : .recalled

            result = RecallMatch(product: product, recalls: filteredRecalls, status: status, barcode: barcode)
            showResult = true

            saveToHistory(barcode: barcode, product: product, recalls: filteredRecalls, status: status, context: context)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func manualSearch(barcode: String, context: ModelContext) async {
        guard !manualProductName.isEmpty else { return }
        isLoading = true
        errorMessage = nil

        do {
            let recalls = try await fdaService.checkProduct(name: manualProductName, brand: "")
            let status: RecallStatus = recalls.isEmpty ? .clear : .recalled
            let product = OFFProduct(
                productName: manualProductName,
                brands: nil,
                imageUrl: nil,
                categories: nil,
                ingredientsText: nil,
                nutriscoreGrade: nil,
                quantity: nil
            )

            result = RecallMatch(product: product, recalls: recalls, status: status, barcode: barcode)
            showResult = true

            saveToHistory(barcode: barcode, product: product, recalls: recalls, status: status, context: context)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func resetScanner() {
        result = nil
        showResult = false
        errorMessage = nil
        manualProductName = ""
        isScanning = true
    }

    private func checkRecalls(for product: OFFProduct?) async throws -> [FDARecall] {
        guard let product else { return [] }
        let name = product.productName ?? ""
        let brand = product.brands ?? ""
        return try await fdaService.checkProduct(name: name, brand: brand)
    }

    private func filterRelevantRecalls(_ recalls: [FDARecall], product: OFFProduct?) -> [FDARecall] {
        guard let product, let productName = product.productName else { return recalls }
        let threshold = 0.15

        let filtered = recalls.filter { recall in
            productName.relevanceScore(comparedTo: recall.productDescription) >= threshold
        }

        return filtered.isEmpty ? recalls : filtered
    }

    private func saveToHistory(barcode: String, product: OFFProduct?, recalls: [FDARecall], status: RecallStatus, context: ModelContext) {
        let item = ScannedItem(
            barcode: barcode,
            productName: product?.productName ?? "Unknown Product",
            brandName: product?.brands ?? "Unknown Brand",
            imageURL: product?.imageUrl,
            recallStatus: status,
            matchedRecallNumbers: recalls.map(\.recallNumber)
        )
        context.insert(item)
        try? context.save()
    }
}
