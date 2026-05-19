import XCTest
@testable import MusicShop

// MARK: - Model Tests

final class ModelTests: XCTestCase {
    
    // MARK: - Product Tests
    
    func testProduct_formattedPrice_isCorrect() {
        let product = Product(id: 1, title: "Test", artist: "Artist",
                              genre: .rock, price: 29.99, quantity: 10)
        XCTAssertEqual(product.formattedPrice, "29.99 BYN")
    }
    
    func testProduct_isInStock_whenQuantityGreaterThanZero() {
        let product = Product(id: 1, title: "Test", artist: "Artist",
                              genre: .rock, price: 29.99, quantity: 5)
        XCTAssertTrue(product.isInStock)
    }
    
    func testProduct_isNotInStock_whenQuantityIsZero() {
        let product = Product(id: 1, title: "Test", artist: "Artist",
                              genre: .rock, price: 29.99, quantity: 0)
        XCTAssertFalse(product.isInStock)
    }
    
    // MARK: - CartItem Tests
    
    func testCartItem_totalPrice_isCorrect() {
        let product = Product(id: 1, title: "Test", artist: "Artist",
                              genre: .pop, price: 20.00, quantity: 10)
        let cartItem = CartItem(id: 1, product: product, quantity: 3)
        XCTAssertEqual(cartItem.totalPrice, 60.00)
    }
    
    func testCartItem_formattedTotalPrice_isCorrect() {
        let product = Product(id: 1, title: "Test", artist: "Artist",
                              genre: .pop, price: 15.50, quantity: 10)
        let cartItem = CartItem(id: 1, product: product, quantity: 2)
        XCTAssertEqual(cartItem.formattedTotalPrice, "31.00 BYN")
    }
    
    // MARK: - String Extension Tests
    
    func testStringExtension_sha256_returnsCorrectLength() {
        let hash = "password".sha256()
        XCTAssertEqual(hash.count, 64, "SHA-256 hash should be 64 characters")
    }
    
    func testStringExtension_sha256_isSameForSameInput() {
        let hash1 = "admin123".sha256()
        let hash2 = "admin123".sha256()
        XCTAssertEqual(hash1, hash2)
    }
    
    func testStringExtension_sha256_isDifferentForDifferentInput() {
        let hash1 = "password1".sha256()
        let hash2 = "password2".sha256()
        XCTAssertNotEqual(hash1, hash2)
    }
    
    func testStringExtension_isValidEmail_trueForValid() {
        XCTAssertTrue("user@example.com".isValidEmail)
        XCTAssertTrue("test.name+tag@sub.domain.org".isValidEmail)
    }
    
    func testStringExtension_isValidEmail_falseForInvalid() {
        XCTAssertFalse("notanemail".isValidEmail)
        XCTAssertFalse("missing@".isValidEmail)
        XCTAssertFalse("@nodomain.com".isValidEmail)
        XCTAssertFalse("".isValidEmail)
    }
    
    func testStringExtension_hasMinLength_trueWhenSufficient() {
        XCTAssertTrue("abcdef".hasMinLength(6))
        XCTAssertTrue("abcdefg".hasMinLength(6))
    }
    
    func testStringExtension_hasMinLength_falseWhenTooShort() {
        XCTAssertFalse("abc".hasMinLength(6))
        XCTAssertFalse("".hasMinLength(1))
    }
    
    // MARK: - UserRole Tests
    
    func testUserRole_rawValue_isCorrect() {
        XCTAssertEqual(User.UserRole.manager.rawValue, "manager")
        XCTAssertEqual(User.UserRole.buyer.rawValue, "buyer")
    }
    
    func testUserRole_initFromRawValue_manager() {
        let role = User.UserRole(rawValue: "manager")
        XCTAssertEqual(role, .manager)
    }
    
    func testUserRole_initFromRawValue_invalidFallsToNil() {
        let role = User.UserRole(rawValue: "admin")
        XCTAssertNil(role)
    }
    
    // MARK: - Genre Tests
    
    func testGenre_allCases_hasEightGenres() {
        XCTAssertEqual(Product.Genre.allCases.count, 8)
    }
    
    func testGenre_initFromRawValue_rock() {
        let genre = Product.Genre(rawValue: "Rock")
        XCTAssertEqual(genre, .rock)
    }
}
