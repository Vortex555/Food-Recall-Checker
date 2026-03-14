import Foundation

struct FDAResponse: Codable, Sendable {
    let meta: FDAMeta?
    let results: [FDARecall]
}

struct FDAMeta: Codable, Sendable {
    let disclaimer: String?
    let lastUpdated: String?
    let results: FDAMetaResults?

    enum CodingKeys: String, CodingKey {
        case disclaimer
        case lastUpdated = "last_updated"
        case results
    }
}

struct FDAMetaResults: Codable, Sendable {
    let skip: Int
    let limit: Int
    let total: Int
}

struct FDARecall: Codable, Identifiable, Sendable {
    var id: String { recallNumber }

    let status: String
    let city: String?
    let state: String?
    let country: String?
    let classification: String
    let productType: String
    let eventId: String
    let recallingFirm: String
    let voluntaryMandated: String
    let distributionPattern: String?
    let recallNumber: String
    let productDescription: String
    let productQuantity: String?
    let reasonForRecall: String
    let recallInitiationDate: String
    let reportDate: String
    let codeInfo: String?
    let terminationDate: String?

    enum CodingKeys: String, CodingKey {
        case status, city, state, country, classification
        case productType = "product_type"
        case eventId = "event_id"
        case recallingFirm = "recalling_firm"
        case voluntaryMandated = "voluntary_mandated"
        case distributionPattern = "distribution_pattern"
        case recallNumber = "recall_number"
        case productDescription = "product_description"
        case productQuantity = "product_quantity"
        case reasonForRecall = "reason_for_recall"
        case recallInitiationDate = "recall_initiation_date"
        case reportDate = "report_date"
        case codeInfo = "code_info"
        case terminationDate = "termination_date"
    }
}
