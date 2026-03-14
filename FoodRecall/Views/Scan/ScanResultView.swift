import SwiftUI
import SwiftData

struct ScanResultView: View {
    let match: RecallMatch
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var scannedItem: ScannedItem?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    statusBanner
                    if let item = scannedItem {
                        FavoriteNotifyButtons(item: item)
                    }
                    productInfoSection
                    if !match.recalls.isEmpty {
                        recallsSection
                    }
                    disclaimerSection
                }
                .padding()
            }
            .navigationTitle("Scan Result")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear { loadScannedItem() }
        }
    }

    private func loadScannedItem() {
        guard let barcode = match.barcode else { return }
        let descriptor = FetchDescriptor<ScannedItem>(
            predicate: #Predicate { $0.barcode == barcode }
        )
        scannedItem = try? modelContext.fetch(descriptor).first
    }

    private var statusBanner: some View {
        VStack(spacing: 12) {
            Image(systemName: statusIcon)
                .font(.system(size: 50))
                .foregroundStyle(statusColor)

            Text(statusText)
                .font(.title2.bold())
                .foregroundStyle(statusColor)

            if match.status == .recalled {
                Text("\(match.recalls.count) recall\(match.recalls.count == 1 ? "" : "s") found")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(statusColor.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var productInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Product Info")
                .font(.headline)

            HStack(alignment: .top, spacing: 16) {
                if let imageUrl = match.product?.imageUrl, let url = URL(string: imageUrl) {
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
                    Text(match.product?.productName ?? "Unknown Product")
                        .font(.body.bold())

                    if let brand = match.product?.brands, !brand.isEmpty {
                        Text(brand)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if let barcode = match.barcode {
                        Text("Barcode: \(barcode)")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
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

            ForEach(match.recalls) { recall in
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

    private var statusIcon: String {
        switch match.status {
        case .clear: return "checkmark.seal.fill"
        case .recalled: return "exclamationmark.triangle.fill"
        case .unknown: return "questionmark.circle.fill"
        }
    }

    private var statusColor: Color {
        switch match.status {
        case .clear: return .green
        case .recalled: return .red
        case .unknown: return .orange
        }
    }

    private var statusText: String {
        switch match.status {
        case .clear: return "No Recalls Found"
        case .recalled: return "Recall Alert"
        case .unknown: return "Unknown Status"
        }
    }
}
