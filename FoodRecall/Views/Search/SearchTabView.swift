import SwiftUI

struct SearchTabView: View {
    @State private var viewModel = SearchViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.results.isEmpty && !viewModel.isLoading {
                    emptyState
                } else {
                    resultsList
                }
            }
            .navigationTitle("Search Recalls")
            .searchable(text: $viewModel.query, prompt: "Search by product or brand name")
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label(
                viewModel.query.isEmpty ? "Search Food Recalls" : "No Results",
                systemImage: viewModel.query.isEmpty ? "magnifyingglass" : "magnifyingglass.circle"
            )
        } description: {
            Text(viewModel.query.isEmpty
                 ? "Search for food products or brands to check for recalls."
                 : "No recalls found for \"\(viewModel.query)\". Try a different search term.")
        }
    }

    private var resultsList: some View {
        List {
            ForEach(viewModel.results) { recall in
                NavigationLink {
                    RecallDetailView(recall: recall)
                } label: {
                    RecallRowView(recall: recall)
                }
            }

            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }

            if viewModel.hasMoreResults {
                Color.clear
                    .frame(height: 1)
                    .onAppear {
                        Task { await viewModel.loadMore() }
                    }
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.caption)
            }
        }
        .listStyle(.plain)
    }
}
