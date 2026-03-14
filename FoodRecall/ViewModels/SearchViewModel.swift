import Foundation

@MainActor
@Observable
final class SearchViewModel {
    var query: String = "" {
        didSet { debounceSearch() }
    }
    var results: [FDARecall] = []
    var isLoading = false
    var errorMessage: String?
    var totalResults = 0
    var hasMoreResults: Bool { results.count < totalResults }

    private let fdaService = FDARecallService()
    private var searchTask: Task<Void, Never>?
    private var currentSkip = 0

    func debounceSearch() {
        searchTask?.cancel()
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            results = []
            totalResults = 0
            errorMessage = nil
            return
        }

        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(Constants.Defaults.searchDebounceMilliseconds))
            guard !Task.isCancelled else { return }
            await performSearch()
        }
    }

    func performSearch() async {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        isLoading = true
        errorMessage = nil
        currentSkip = 0

        do {
            let response = try await fdaService.searchRecalls(query: trimmed, skip: 0)
            results = response.results
            totalResults = response.meta?.results?.total ?? response.results.count
        } catch is CancellationError {
            // Ignore
        } catch {
            errorMessage = error.localizedDescription
            results = []
        }

        isLoading = false
    }

    func loadMore() async {
        guard hasMoreResults, !isLoading else { return }
        isLoading = true

        currentSkip = results.count

        do {
            let response = try await fdaService.searchRecalls(query: query, skip: currentSkip)
            results.append(contentsOf: response.results)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
