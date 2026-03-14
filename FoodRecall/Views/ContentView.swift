import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ScanTabView()
                .tabItem {
                    Label("Scan", systemImage: "barcode.viewfinder")
                }

            SearchTabView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }

            RecallFeedTabView()
                .tabItem {
                    Label("Recalls", systemImage: "exclamationmark.triangle")
                }

            HistoryTabView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
        }
    }
}
