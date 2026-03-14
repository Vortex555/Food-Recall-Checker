import SwiftUI
import SwiftData

struct RecallDetailView: View {
    let recall: FDARecall
    @Environment(\.modelContext) private var modelContext
    @State private var existingItem: ScannedItem?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                classificationBanner
                actionButtons
                detailSection("Product", content: recall.productDescription)
                detailSection("Reason for Recall", content: recall.reasonForRecall)
                detailSection("Recalling Firm", content: recall.recallingFirm)

                HStack(spacing: 20) {
                    infoCard(title: "Status", value: recall.status)
                    infoCard(title: "Type", value: recall.voluntaryMandated)
                }

                if let distribution = recall.distributionPattern, !distribution.isEmpty {
                    detailSection("Distribution", content: distribution)
                }

                if let codeInfo = recall.codeInfo, !codeInfo.isEmpty {
                    detailSection("Product Codes", content: codeInfo)
                }

                if let quantity = recall.productQuantity, !quantity.isEmpty {
                    detailSection("Quantity", content: quantity)
                }

                datesSection

                Text("Recall #\(recall.recallNumber) • Event #\(recall.eventId)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)

                disclaimerText
            }
            .padding()
        }
        .navigationTitle("Recall Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { checkIfWatching() }
    }

    @ViewBuilder
    private var actionButtons: some View {
        if let item = existingItem {
            FavoriteNotifyButtons(item: item)
        } else {
            Button {
                let item = ScannedItem(
                    barcode: recall.recallNumber,
                    productName: recall.productDescription.prefix(100).description,
                    brandName: recall.recallingFirm,
                    recallStatus: .recalled,
                    matchedRecallNumbers: [recall.recallNumber]
                )
                modelContext.insert(item)
                try? modelContext.save()
                existingItem = item
            } label: {
                Label("Save to History", systemImage: "plus.circle")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.accentColor.opacity(0.1))
                    .foregroundStyle(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private func checkIfWatching() {
        let recallNumber = recall.recallNumber
        let descriptor = FetchDescriptor<ScannedItem>(
            predicate: #Predicate { $0.barcode == recallNumber }
        )
        if let item = try? modelContext.fetch(descriptor).first {
            existingItem = item
        }
    }

    private var classificationBanner: some View {
        let classification = RecallClassification(from: recall.classification)

        return VStack(spacing: 8) {
            Text(recall.classification)
                .font(.title3.bold())
                .foregroundStyle(.white)

            Text(classification?.severity ?? "")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))

            if let classification {
                Text(classification.description)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(classification?.color ?? .gray)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func detailSection(_ title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            Text(content)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private func infoCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var datesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Dates")
                .font(.headline)

            HStack {
                dateRow(label: "Initiated", date: recall.recallInitiationDate)
                Spacer()
                dateRow(label: "Reported", date: recall.reportDate)
            }

            if let termDate = recall.terminationDate, !termDate.isEmpty {
                dateRow(label: "Terminated", date: termDate)
            }
        }
    }

    private func dateRow(label: String, date: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(FDADateFormatter.displayString(from: date))
                .font(.subheadline)
        }
    }

    private var disclaimerText: some View {
        Text("Data sourced from the FDA openFDA API. This information is for reference only and may not reflect the current status of this recall.")
            .font(.caption)
            .foregroundStyle(.tertiary)
            .multilineTextAlignment(.center)
            .padding(.top, 8)
    }
}
