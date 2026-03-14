import Foundation

protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
}

extension Endpoint {
    var url: URL? {
        var components = URLComponents(string: baseURL)
        components?.path = path
        components?.queryItems = queryItems.isEmpty ? nil : queryItems
        return components?.url
    }
}

struct FDAEnforcementEndpoint: Endpoint {
    let baseURL = Constants.API.fdaBaseURL
    let path = Constants.API.fdaEnforcementPath

    let search: String?
    let sort: String?
    let limit: Int
    let skip: Int

    init(search: String? = nil, sort: String? = nil, limit: Int = Constants.Defaults.pageSize, skip: Int = 0) {
        self.search = search
        self.sort = sort
        self.limit = limit
        self.skip = skip
    }

    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []
        if let search {
            items.append(URLQueryItem(name: "search", value: search))
        }
        if let sort {
            items.append(URLQueryItem(name: "sort", value: sort))
        }
        items.append(URLQueryItem(name: "limit", value: "\(limit)"))
        items.append(URLQueryItem(name: "skip", value: "\(skip)"))
        return items
    }
}

struct OFFProductEndpoint: Endpoint {
    let baseURL = Constants.API.offBaseURL
    let barcode: String

    var path: String {
        "\(Constants.API.offProductPath)/\(barcode).json"
    }

    var queryItems: [URLQueryItem] {
        [URLQueryItem(name: "fields", value: "product_name,brands,image_url,categories,ingredients_text,nutriscore_grade,quantity")]
    }
}
