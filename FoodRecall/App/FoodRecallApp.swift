import SwiftUI
import SwiftData

@main
struct FoodRecallApp: App {
    @Environment(\.scenePhase) private var scenePhase

    let modelContainer: ModelContainer

    init() {
        let container = try! ModelContainer(for: ScannedItem.self)
        self.modelContainer = container
        BackgroundRefreshManager.registerTask(modelContainer: container)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await NotificationManager.shared.checkAuthorization()
                }
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .background {
                        BackgroundRefreshManager.scheduleNextRefresh()
                    }
                }
        }
        .modelContainer(modelContainer)
    }
}
