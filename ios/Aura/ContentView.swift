import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject private var dailyLogViewModel: DailyLogViewModel
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    @EnvironmentObject private var securityViewModel: SecurityViewModel

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Today", systemImage: "sun.max.fill")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "calendar")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(.indigo)
    }
}

#Preview {
    let container = ModelContainer.preview
    return ContentView()
        .environmentObject(DailyLogViewModel.preview)
        .environmentObject(SettingsViewModel())
        .environmentObject(SecurityViewModel())
        .modelContainer(container)
}

