import Foundation

enum Constants {
    enum API {
        static let fdaBaseURL = "https://api.fda.gov"
        static let fdaEnforcementPath = "/food/enforcement.json"
        static let offBaseURL = "https://world.openfoodfacts.net"
        static let offProductPath = "/api/v2/product"
        static let offUserAgent = "FoodRecall iOS App/1.0"
    }

    enum Defaults {
        static let pageSize = 25
        static let searchDebounceMilliseconds = 500
        static let feedCacheTTLSeconds: TimeInterval = 900 // 15 minutes
    }
}
