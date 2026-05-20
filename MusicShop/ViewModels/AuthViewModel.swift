import Foundation
import Combine

// MARK: - Auth ViewModel

final class AuthViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var currentUser: User?
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    
    // MARK: - Dependencies
    
    private let dbService = DatabaseService.shared
    private let udService = UserDefaultsService.shared
    
    // MARK: - Initializer
    
    init() {
        restoreSession()
    }
    
    // MARK: - Session Restore
    
    private func restoreSession() {
        if udService.isSessionActive,
           let userId = udService.loggedInUserId,
           let username = udService.loggedInUsername {
            // Restore user from stored session
            let roleStr = udService.loggedInUserRole ?? "buyer"
            let role = User.UserRole(rawValue: roleStr) ?? .buyer
            currentUser = User(id: userId, username: username, email: "", passwordHash: "", role: role)
            isLoggedIn = true
        }
    }
    
    // MARK: - Login
    
    func login(username: String, password: String) {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = NSLocalizedString("error_empty_fields", comment: "")
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let user = self.dbService.loginUser(username: username, password: password)
            
            DispatchQueue.main.async {
                self.isLoading = false
                if let user = user {
                    self.currentUser = user
                    self.isLoggedIn = true
                    self.udService.saveSession(user: user)
                } else {
                    self.errorMessage = NSLocalizedString("error_invalid_credentials", comment: "")
                }
            }
        }
    }
    
    // MARK: - Register
    
    func register(username: String, email: String, password: String, confirmPassword: String) {
        guard !username.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = NSLocalizedString("error_empty_fields", comment: "")
            return
        }
        guard email.isValidEmail else {
            errorMessage = NSLocalizedString("error_invalid_email", comment: "")
            return
        }
        guard password == confirmPassword else {
            errorMessage = NSLocalizedString("error_passwords_mismatch", comment: "")
            return
        }
        guard password.hasMinLength(6) else {
            errorMessage = NSLocalizedString("error_password_too_short", comment: "")
            return
        }
        guard username.hasMinLength(3) else {
            errorMessage = NSLocalizedString("error_username_too_short", comment: "")
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let user = self.dbService.registerUser(username: username, email: email, password: password)
            
            DispatchQueue.main.async {
                self.isLoading = false
                if let user = user {
                    self.currentUser = user
                    self.isLoggedIn = true
                    self.udService.saveSession(user: user)
                } else {
                    self.errorMessage = NSLocalizedString("error_registration_failed", comment: "")
                }
            }
        }
    }
    
    // MARK: - Logout
    
    func logout() {
        currentUser = nil
        isLoggedIn = false
        udService.clearSession()
    }
}
