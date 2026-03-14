import SwiftUI

struct RecallFeedTabView: View {
    @State private var viewModel = RecallFeedViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterBar
                    .padding(.horizontal)
                    .padding(.vertical, 8)

                Group {
                    if viewModel.filteredRecalls.isEmpty && !viewModel.isLoading {
                        emptyState
                    } else {
                        recallList
                    }
                }
            }
            .navigationTitle("Recent Recalls")
            .task {
                await viewModel.loadRecalls()
            }
            .refreshable {
                await viewModel.loadRecalls(forceRefresh: true)
            }
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    title: "All",
                    isSelected: viewModel.selectedClassification == nil
                ) {
                    viewModel.selectedClassification = nil
                }

                ForEach(RecallClassification.allCases, id: \.self) { classification in
                    FilterChip(
                        title: classification.rawValue,
                        color: classification.color,
                        isSelected: viewModel.selectedClassification == classification
                    ) {
                        viewModel.selectedClassification = classification
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Recalls", systemImage: "checkmark.circle")
        } description: {
            if viewModel.errorMessage != nil {
                Text(viewModel.errorMessage!)
            } else {
                Text("No recalls found for this filter.")
            }
        }
    }

    private var recallList: some View {
        List {
            ForEach(viewModel.filteredRecalls) { recall in
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

            if viewModel.hasMoreResults && viewModel.selectedClassification == nil {
                Color.clear
                    .frame(height: 1)
                    .onAppear {
                        Task { await viewModel.loadMore() }
                    }
            }
        }
        .listStyle(.plain)
    }
}

struct FilterChip: View {
    let title: String
    var color: Color = .accentColor
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.bold())
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? color : color.opacity(0.15))
                .foregroundStyle(isSelected ? .white : color)
                .clipShape(Capsule())
        }
    }
}
