import SwiftUI
import SwiftData

struct FavoriteNotifyButtons: View {
    let item: ScannedItem
    @Environment(\.modelContext) private var modelContext
    @State private var isFavorite: Bool
    @State private var isNotifying: Bool

    init(item: ScannedItem) {
        self.item = item
        self._isFavorite = State(initialValue: item.isFavorite)
        self._isNotifying = State(initialValue: item.notifyOnRecall)
    }

    var body: some View {
        HStack(spacing: 12) {
            Button {
                item.isFavorite.toggle()
                isFavorite = item.isFavorite
                try? modelContext.save()
            } label: {
                Label(
                    isFavorite ? "Favorited" : "Favorite",
                    systemImage: isFavorite ? "star.fill" : "star"
                )
                .font(.subheadline.bold())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isFavorite ? Color.yellow.opacity(0.15) : Color(.secondarySystemBackground))
                .foregroundStyle(isFavorite ? .yellow : .secondary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Button {
                Task { await toggleNotify() }
            } label: {
                Label(
                    isNotifying ? "Notifying" : "Notify Me",
                    systemImage: isNotifying ? "bell.fill" : "bell"
                )
                .font(.subheadline.bold())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isNotifying ? Color.blue.opacity(0.15) : Color(.secondarySystemBackground))
                .foregroundStyle(isNotifying ? .blue : .secondary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private func toggleNotify() async {
        if !item.notifyOnRecall {
            let manager = NotificationManager.shared
            if !manager.isAuthorized {
                let granted = await manager.requestAuthorization()
                guard granted else { return }
            }
            item.notifyOnRecall = true
        } else {
            item.notifyOnRecall = false
        }
        isNotifying = item.notifyOnRecall
        try? modelContext.save()
    }
}
