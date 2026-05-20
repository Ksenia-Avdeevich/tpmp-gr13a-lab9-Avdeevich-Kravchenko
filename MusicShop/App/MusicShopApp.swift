import SwiftUI

@main
struct MusicShopApp: App {

    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .onAppear {
                    DatabaseService.shared.setup()
                }
        }
    }

    init() {
        // Сбрасываем сессию при запуске UI-тестов
        // чтобы всегда начинать с экрана логина
        if ProcessInfo.processInfo.environment["RESET_USER_DEFAULTS"] == "1" {
            UserDefaultsService.shared.clearSession()
        }
    }
}
