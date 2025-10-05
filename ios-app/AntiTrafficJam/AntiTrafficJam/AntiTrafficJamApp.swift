import SwiftUI
import FirebaseCore

@main
struct AntiTrafficJamApp: App {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var firebaseService = FirebaseService()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(locationManager)
                .environmentObject(firebaseService)
                .preferredColorScheme(.dark)
        }
    }
}
