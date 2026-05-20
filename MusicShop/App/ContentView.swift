import SwiftUI

// MARK: - Content View

struct ContentView: View {
    
    // MARK: - Environment
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if authViewModel.isLoggedIn {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authViewModel.isLoggedIn)
    }
}
