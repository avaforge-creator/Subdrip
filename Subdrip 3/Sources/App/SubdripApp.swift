import SwiftUI

@main
struct SubdripApp: App {
    @StateObject private var subscriptionStore = SubscriptionStore()
    @AppStorage("isDarkMode") private var isDarkMode = true
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(subscriptionStore)
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
