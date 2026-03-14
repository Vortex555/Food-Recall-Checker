import Foundation

@MainActor
@Observable
final class RecallFeedViewModel {
    var recalls: [FDARecall] = []
    var isLoading = false
    var errorMessage: String?
    var totalResults = 0
    var hasMoreResults: Bool { recalls.count < totalResults }
    var selectedClassification: RecallClassification?

    private let fdaService = FDARecallService()
    private var lastFetchDate: Date?

    var filteredRecalls: [FDARecall] {
        guard let classification = selectedClassification else { return recalls }
        return recalls.filter { $0.classification == classification.rawValue }
    }

    func loadRecalls(forceRefresh: Bool = false) async {
        if !forceRefresh,
           let lastFetch = lastFetchDate,
           Date().timeIntervalSince(lastFetch) < Constants.Defaults.feedCacheTTLSeconds,
           !recalls.isEmpty {
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await fdaService.recentRecalls()
            recalls = response.results
            totalResults = response.meta?.results?.total ?? response.results.count
            lastFetchDate = Date()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func loadMore() async {
        guard hasMoreResults, !isLoading else { return }
        isLoading = true

        do {
            let response = try await fdaService.recentRecalls(skip: recalls.count)
            recalls.append(contentsOf: response.results)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
