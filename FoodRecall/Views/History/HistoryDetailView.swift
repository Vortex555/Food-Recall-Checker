import SwiftUI
import SwiftData

struct HistoryDetailView: View {
    let item: ScannedItem
    @Environment(\.modelContext) private var modelContext
    @State private var recalls: [FDARecall] = []
    @State private var isLoading = true

    private let fdaService = FDARecallService()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                statusBanner
                FavoriteNotifyButtons(item: item)
                productInfoSection

                if isLoading {
                    ProgressView("Checking recalls...")
                        .padding()
                } else if !recalls.isEmpty {
                    recallsSection
                }

                disclaimerSection
            }
            .padding()
        }
        .navigationTitle("Product Details")
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadRecalls() }
    }

    private func loadRecalls() async {
        isLoading = true
        do {
            let results = try await fdaService.checkProduct(name: item.productName, brand: item.brandName)
            recalls = results
            item.recallStatus = results.isEmpty ? .clear : .recalled
            item.matchedRecallNumbers = results.map(\.recallNumber)
            item.lastCheckedDate = Date()
            try? modelContext.save()
        } catch {
            // If fetch fails, leave existing state
        }
        isLoading = false
    }

    private var statusBanner: some View {
        let status = recalls.isEmpty && !isLoading ? RecallStatus.clear : item.recallStatus

        return VStack(spacing: 12) {
            Image(systemName: statusIcon(for: status))
                .font(.system(size: 50))
                .foregroundStyle(statusColor(for: status))

            Text(statusText(for: status))
                .font(.title2.bold())
                .foregroundStyle(statusColor(for: status))

            if !recalls.isEmpty {
                Text("\(recalls.count) recall\(recalls.count == 1 ? "" : "s") found")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(statusColor(for: status).opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var productInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Product Info")
                .font(.headline)

            HStack(alignment: .top, spacing: 16) {
                if let imageURL = item.imageURL, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.quaternary)
                            .overlay {
                                Image(systemName: "photo")
                                    .foregroundStyle(.secondary)
                            }
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(item.productName)
                        .font(.body.bold())

                    if !item.brandName.isEmpty, item.brandName != "Unknown Brand" {
                        Text(item.brandName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Text("Barcode: \(item.barcode)")
                        .font(.caption)
                        .foregroundStyle(.tertiary)

                    Text("Last checked: \(item.lastCheckedDate, style: .relative) ago")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                Spacer()
            }
        }
        .padding()
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var recallsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Matching Recalls")
                .font(.headline)

            ForEach(recalls) { recall in
                NavigationLink {
                    RecallDetailView(recall: recall)
                } label: {
                    RecallRowView(recall: recall)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var disclaimerSection: some View {
        Text("This data is provided by the FDA openFDA API for informational purposes only. It may not reflect the most current recall status. When in doubt, contact the manufacturer directly.")
            .font(.caption)
            .foregroundStyle(.tertiary)
            .multilineTextAlignment(.center)
            .padding(.top, 8)
    }

    private func statusIcon(for status: RecallStatus) -> String {
        switch status {
        case .clear: return "checkmark.seal.fill"
        case .recalled: return "exclamationmark.triangle.fill"
        case .unknown: return "questionmark.circle.fill"
        }
    }

    private func statusColor(for status: RecallStatus) -> Color {
        switch status {
        case .clear: return .green
        case .recalled: return .red
        case .unknown: return .orange
        }
    }

    private func statusText(for status: RecallStatus) -> String {
        switch status {
        case .clear: return "No Recalls Found"
        case .recalled: return "Recall Alert"
        case .unknown: return "Unknown Status"
        }
    }
}
