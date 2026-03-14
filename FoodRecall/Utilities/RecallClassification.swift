import SwiftUI

enum RecallClassification: String, CaseIterable {
    case classI = "Class I"
    case classII = "Class II"
    case classIII = "Class III"

    init?(from string: String) {
        self.init(rawValue: string)
    }

    var color: Color {
        switch self {
        case .classI: return .red
        case .classII: return .orange
        case .classIII: return .yellow
        }
    }

    var severity: String {
        switch self {
        case .classI: return "Dangerous"
        case .classII: return "Moderate"
        case .classIII: return "Low Risk"
        }
    }

    var description: String {
        switch self {
        case .classI:
            return "Reasonable probability that use of or exposure to the product will cause serious adverse health consequences or death."
        case .classII:
            return "Use of or exposure to the product may cause temporary or medically reversible adverse health consequences."
        case .classIII:
            return "Use of or exposure to the product is not likely to cause adverse health consequences."
        }
    }
}
