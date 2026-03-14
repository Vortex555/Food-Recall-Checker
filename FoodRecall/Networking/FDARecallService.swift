import Foundation

struct FDARecallService {
    private let client = APIClient.shared

    func searchRecalls(query: String, limit: Int = Constants.Defaults.pageSize, skip: Int = 0) async throws -> FDAResponse {
        let sanitized = query.replacingOccurrences(of: "\"", with: "")
        let searchQuery = "product_description:\"\(sanitized)\"+recalling_firm:\"\(sanitized)\""
        let endpoint = FDAEnforcementEndpoint(search: searchQuery, sort: "report_date:desc", limit: limit, skip: skip)
        return try await client.fetch(endpoint, as: FDAResponse.self)
    }

    func recentRecalls(limit: Int = Constants.Defaults.pageSize, skip: Int = 0) async throws -> FDAResponse {
        let endpoint = FDAEnforcementEndpoint(sort: "report_date:desc", limit: limit, skip: skip)
        return try await client.fetch(endpoint, as: FDAResponse.self)
    }

    func checkProduct(name: String, brand: String) async throws -> [FDARecall] {
        let sanitizedName = name.replacingOccurrences(of: "\"", with: "")
        let sanitizedBrand = brand.replacingOccurrences(of: "\"", with: "")

        var allRecalls: [FDARecall] = []

        // Search by brand/firm name
        if !sanitizedBrand.isEmpty {
            let brandEndpoint = FDAEnforcementEndpoint(
                search: "recalling_firm:\"\(sanitizedBrand)\"",
                sort: "report_date:desc",
                limit: 50
            )
            if let response = try? await client.fetch(brandEndpoint, as: FDAResponse.self) {
                allRecalls.append(contentsOf: response.results)
            }
        }

        // Search by product description
        if !sanitizedName.isEmpty {
            let nameEndpoint = FDAEnforcementEndpoint(
                search: "product_description:\"\(sanitizedName)\"",
                sort: "report_date:desc",
                limit: 50
            )
            if let response = try? await client.fetch(nameEndpoint, as: FDAResponse.self) {
                allRecalls.append(contentsOf: response.results)
            }
        }

        // Deduplicate by recall number
        var seen = Set<String>()
        return allRecalls.filter { seen.insert($0.recallNumber).inserted }
    }
}
