import SwiftUI
import SwiftData

struct HistoryTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ScannedItem.scanDate, order: .reverse) private var scannedItems: [ScannedItem]
    @State private var viewModel = HistoryViewModel()
    @State private var showFavoritesOnly = false

    private var displayedItems: [ScannedItem] {
        showFavoritesOnly ? scannedItems.filter(\.isFavorite) : scannedItems
    }

    var body: some View {
        NavigationStack {
            Group {
                if scannedItems.isEmpty {
                    emptyState
                } else if displayedItems.isEmpty {
                    ContentUnavailableView {
                        Label("No Favorites", systemImage: "star")
                    } description: {
                        Text("Swipe right on a product to add it to your favorites.")
                    }
                } else {
                    historyList
                }
            }
            .navigationTitle("Scan History")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !scannedItems.isEmpty {
                        Button {
                            withAnimation { showFavoritesOnly.toggle() }
                        } label: {
                            Image(systemName: showFavoritesOnly ? "star.fill" : "star")
                                .foregroundStyle(showFavoritesOnly ? .yellow : .secondary)
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if scannedItems.contains(where: \.isFavorite) {
                        Button {
                            Task { await viewModel.recheckAllFavorites(context: modelContext) }
                        } label: {
                            Image(systemName: "arrow.triangle.2.circlepath")
                        }
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Scan History", systemImage: "clock.arrow.circlepath")
        } description: {
            Text("Products you scan will appear here so you can track their recall status.")
        }
    }

    private var historyList: some View {
        List {
            ForEach(displayedItems) { item in
                NavigationLink {
                    historyDetail(for: item)
                } label: {
                    HistoryRowView(item: item)
                }
                .swipeActions(edge: .leading) {
                    Button {
                        viewModel.toggleFavorite(item, context: modelContext)
                    } label: {
                        Label(
                            item.isFavorite ? "Unfavorite" : "Favorite",
                            systemImage: item.isFavorite ? "star.slash" : "star.fill"
                        )
                    }
                    .tint(.yellow)

                    Button {
                        Task { await viewModel.toggleNotification(item, context: modelContext) }
                    } label: {
                        Label(
                            item.notifyOnRecall ? "Mute" : "Notify",
                            systemImage: item.notifyOnRecall ? "bell.slash.fill" : "bell.fill"
                        )
                    }
                    .tint(.blue)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        viewModel.deleteItem(item, context: modelContext)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
    }

    private func historyDetail(for item: ScannedItem) -> some View {
        HistoryDetailView(item: item)
    }
}
