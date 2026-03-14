import SwiftUI

struct HistoryRowView: View {
    let item: ScannedItem

    var body: some View {
        HStack(spacing: 12) {
            if let imageURL = item.imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    placeholderImage
                }
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                placeholderImage
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(item.productName)
                        .font(.subheadline.bold())
                        .lineLimit(1)

                    if item.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                    }

                    if item.notifyOnRecall {
                        Image(systemName: "bell.fill")
                            .font(.caption2)
                            .foregroundStyle(.blue)
                    }
                }

                Text(item.brandName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Text(item.scanDate, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            statusIndicator
        }
        .padding(.vertical, 4)
    }

    private var placeholderImage: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(.quaternary)
            .frame(width: 50, height: 50)
            .overlay {
                Image(systemName: "carrot")
                    .foregroundStyle(.secondary)
            }
    }

    private var statusIndicator: some View {
        VStack(spacing: 4) {
            Image(systemName: statusIcon)
                .font(.title3)
                .foregroundStyle(statusColor)

            Text(statusLabel)
                .font(.caption2)
                .foregroundStyle(statusColor)
        }
    }

    private var statusIcon: String {
        switch item.recallStatus {
        case .clear: return "checkmark.circle.fill"
        case .recalled: return "exclamationmark.triangle.fill"
        case .unknown: return "questionmark.circle.fill"
        }
    }

    private var statusColor: Color {
        switch item.recallStatus {
        case .clear: return .green
        case .recalled: return .red
        case .unknown: return .orange
        }
    }

    private var statusLabel: String {
        switch item.recallStatus {
        case .clear: return "Clear"
        case .recalled: return "Recalled"
        case .unknown: return "Unknown"
        }
    }
}
