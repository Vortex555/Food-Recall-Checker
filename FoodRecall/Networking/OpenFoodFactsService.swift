import Foundation

struct OpenFoodFactsService {
    private let client = APIClient.shared

    func lookupBarcode(_ barcode: String) async throws -> OFFProduct? {
        let endpoint = OFFProductEndpoint(barcode: barcode)

        do {
            let response = try await client.fetch(endpoint, as: OFFResponse.self)
            guard response.status == 1 else { return nil }
            return response.product
        } catch APIError.notFound {
            return nil
        }
    }

    /// Try the barcode as-is, then try stripping/adding leading zero (UPC-A ↔ EAN-13)
    func lookupBarcodeWithFallback(_ barcode: String) async throws -> OFFProduct? {
        if let product = try await lookupBarcode(barcode) {
            return product
        }

        // EAN-13 with leading 0 → try as UPC-A (strip the zero)
        if barcode.count == 13 && barcode.hasPrefix("0") {
            let upcA = String(barcode.dropFirst())
            return try await lookupBarcode(upcA)
        }

        // UPC-A → try as EAN-13 (add leading zero)
        if barcode.count == 12 {
            let ean13 = "0" + barcode
            return try await lookupBarcode(ean13)
        }

        return nil
    }
}
