import Foundation
import CryptoKit

// MARK: - String Extensions

extension String {
    
    /// Computes SHA-256 hash of the string
    func sha256() -> String {
        let data = Data(self.utf8)
        let hash = SHA256.hash(data: data)
        return hash.map { String(format: "%02x", $0) }.joined()
    }
    
    /// Returns localized string
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    /// Validates email format
    var isValidEmail: Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
    
    /// Validates minimum length
    func hasMinLength(_ length: Int) -> Bool {
        self.count >= length
    }
}
