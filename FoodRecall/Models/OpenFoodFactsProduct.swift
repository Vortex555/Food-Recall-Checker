import Foundation

struct OFFResponse: Codable, Sendable {
    let code: String
    let status: Int
    let statusVerbose: String?
    let product: OFFProduct?

    enum CodingKeys: String, CodingKey {
        case code, status, product
        case statusVerbose = "status_verbose"
    }
}

struct OFFProduct: Codable, Sendable {
    let productName: String?
    let brands: String?
    let imageUrl: String?
    let categories: String?
    let ingredientsText: String?
    let nutriscoreGrade: String?
    let quantity: String?

    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case brands
        case imageUrl = "image_url"
        case categories
        case ingredientsText = "ingredients_text"
        case nutriscoreGrade = "nutriscore_grade"
        case quantity
    }
}
