import Foundation

extension String {
    private static let stopWords: Set<String> = [
        "the", "a", "an", "and", "or", "but", "in", "on", "at", "to", "for",
        "of", "with", "by", "from", "is", "it", "its", "as", "are", "was",
        "were", "been", "be", "have", "has", "had", "do", "does", "did",
        "will", "would", "could", "should", "may", "might", "shall", "can",
        "oz", "lb", "lbs", "kg", "g", "ml", "ct", "pk", "pack", "count"
    ]

    func relevanceScore(comparedTo other: String) -> Double {
        let selfTokens = tokenize()
        let otherTokens = other.tokenize()

        guard !selfTokens.isEmpty && !otherTokens.isEmpty else { return 0 }

        let intersection = selfTokens.intersection(otherTokens)
        let union = selfTokens.union(otherTokens)

        guard !union.isEmpty else { return 0 }

        return Double(intersection.count) / Double(union.count)
    }

    private func tokenize() -> Set<String> {
        let words = self
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count > 1 && !Self.stopWords.contains($0) }
        return Set(words)
    }
}
