import SwiftUI

struct RecallRowView: View {
    let recall: FDARecall

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                classificationBadge
                Spacer()
                Text(FDADateFormatter.displayString(from: recall.reportDate))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(recall.productDescription)
                .font(.subheadline)
                .lineLimit(2)

            HStack {
                Text(recall.recallingFirm)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                statusBadge
            }
        }
        .padding(.vertical, 4)
    }

    private var classificationBadge: some View {
        let classification = RecallClassification(from: recall.classification)
        return Text(recall.classification)
            .font(.caption2.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(classification?.color ?? .gray)
            .clipShape(Capsule())
    }

    private var statusBadge: some View {
        Text(recall.status)
            .font(.caption2)
            .foregroundStyle(recall.status == "Ongoing" ? .red : .secondary)
    }
}
