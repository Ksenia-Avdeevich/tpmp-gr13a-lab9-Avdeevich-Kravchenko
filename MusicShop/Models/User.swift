import Foundation

// MARK: - User Model

struct User: Identifiable, Codable {
    let id: Int
    var username: String
    var email: String
    var passwordHash: String
    var role: UserRole
    var createdAt: Date
    
    // MARK: - Nested Types
    
    enum UserRole: String, Codable {
        case manager
        case buyer
    }
    
    // MARK: - Initializer
    
    init(id: Int = 0,
         username: String,
         email: String,
         passwordHash: String,
         role: UserRole = .buyer,
         createdAt: Date = Date()) {
        self.id = id
        self.username = username
        self.email = email
        self.passwordHash = passwordHash
        self.role = role
        self.createdAt = createdAt
    }
}
