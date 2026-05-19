import Foundation

// MARK: - UserDefaults Service

final class UserDefaultsService {
    
    // MARK: - Singleton
    
    static let shared = UserDefaultsService()
    
    // MARK: - Keys
    
    private enum Keys {
        static let loggedInUserId = "loggedInUserId"
        static let loggedInUsername = "loggedInUsername"
        static let loggedInUserRole = "loggedInUserRole"
        static let selectedLanguage = "selectedLanguage"
        static let isDarkMode = "isDarkMode"
        static let lastSearchQuery = "lastSearchQuery"
        static let onboardingCompleted = "onboardingCompleted"
        static let preferredGenre = "preferredGenre"
    }
    
    private let defaults = UserDefaults.standard
    
    // MARK: - Initializer
    
    private init() {}
    
    // MARK: - Session Management
    
    var loggedInUserId: Int? {
        get {
            let id = defaults.integer(forKey: Keys.loggedInUserId)
            return id == 0 ? nil : id
        }
        set { defaults.set(newValue, forKey: Keys.loggedInUserId) }
    }
    
    var loggedInUsername: String? {
        get { defaults.string(forKey: Keys.loggedInUsername) }
        set { defaults.set(newValue, forKey: Keys.loggedInUsername) }
    }
    
    var loggedInUserRole: String? {
        get { defaults.string(forKey: Keys.loggedInUserRole) }
        set { defaults.set(newValue, forKey: Keys.loggedInUserRole) }
    }
    
    var isSessionActive: Bool {
        loggedInUserId != nil
    }
    
    func saveSession(user: User) {
        loggedInUserId = user.id
        loggedInUsername = user.username
        loggedInUserRole = user.role.rawValue
    }
    
    func clearSession() {
        defaults.removeObject(forKey: Keys.loggedInUserId)
        defaults.removeObject(forKey: Keys.loggedInUsername)
        defaults.removeObject(forKey: Keys.loggedInUserRole)
    }
    
    // MARK: - App Preferences
    
    var selectedLanguage: String {
        get { defaults.string(forKey: Keys.selectedLanguage) ?? "ru" }
        set { defaults.set(newValue, forKey: Keys.selectedLanguage) }
    }
    
    var isDarkMode: Bool {
        get { defaults.bool(forKey: Keys.isDarkMode) }
        set { defaults.set(newValue, forKey: Keys.isDarkMode) }
    }
    
    var lastSearchQuery: String {
        get { defaults.string(forKey: Keys.lastSearchQuery) ?? "" }
        set { defaults.set(newValue, forKey: Keys.lastSearchQuery) }
    }
    
    var onboardingCompleted: Bool {
        get { defaults.bool(forKey: Keys.onboardingCompleted) }
        set { defaults.set(newValue, forKey: Keys.onboardingCompleted) }
    }
    
    var preferredGenre: String {
        get { defaults.string(forKey: Keys.preferredGenre) ?? "All" }
        set { defaults.set(newValue, forKey: Keys.preferredGenre) }
    }
}
