import SwiftUI

// MARK: - App Entry Point

@main
struct MusicShopApp: App {
    
    // MARK: - Properties
    
    @StateObject private var authViewModel = AuthViewModel()
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .onAppear {
                    DatabaseService.shared.setup()
                }
        }
    }
}
