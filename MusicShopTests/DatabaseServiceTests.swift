import XCTest
@testable import MusicShop

// MARK: - Database Service Tests

final class DatabaseServiceTests: XCTestCase {
    
    var sut: DatabaseService!
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        sut = DatabaseService.shared
        sut.setup()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Product Tests
    
    func testFetchAllProducts_returnsNonEmptyList() {
        let products = sut.fetchAllProducts()
        XCTAssertFalse(products.isEmpty, "Products list should not be empty after seeding")
    }
    
    func testFetchAllProducts_returnsValidProducts() {
        let products = sut.fetchAllProducts()
        for product in products {
            XCTAssertGreaterThan(product.id, 0, "Product ID must be positive")
            XCTAssertFalse(product.title.isEmpty, "Product title must not be empty")
            XCTAssertFalse(product.artist.isEmpty, "Artist name must not be empty")
            XCTAssertGreaterThan(product.price, 0, "Price must be positive")
        }
    }
    
    func testSearchProducts_withValidQuery_returnsResults() {
        let results = sut.searchProducts(query: "Pink Floyd")
        XCTAssertFalse(results.isEmpty, "Search for 'Pink Floyd' should return results")
    }
    
    func testSearchProducts_withArtistName_returnsMatchingProducts() {
        let results = sut.searchProducts(query: "Adele")
        XCTAssertTrue(results.contains { $0.artist == "Adele" })
    }
    
    func testSearchProducts_withGenre_returnsMatchingProducts() {
        let results = sut.searchProducts(query: "Rock")
        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.allSatisfy { $0.genre == .rock })
    }
    
    func testSearchProducts_withEmptyQuery_handlesGracefully() {
        let results = sut.searchProducts(query: "")
        // Empty query returns all or none — should not crash
        XCTAssertNotNil(results)
    }
    
    func testSearchProducts_withNonexistentQuery_returnsEmpty() {
        let results = sut.searchProducts(query: "ZZZZNOTEXIST12345")
        XCTAssertTrue(results.isEmpty, "Search for non-existent item should return empty list")
    }
    
    // MARK: - User Tests
    
    func testRegisterUser_withValidData_succeeds() {
        let timestamp = Int(Date().timeIntervalSince1970)
        let user = sut.registerUser(
            username: "testuser_\(timestamp)",
            email: "test_\(timestamp)@test.com",
            password: "password123"
        )
        XCTAssertNotNil(user, "Registration with valid data should succeed")
        XCTAssertGreaterThan(user?.id ?? 0, 0)
    }
    
    func testLoginUser_withCorrectCredentials_returnsUser() {
        let timestamp = Int(Date().timeIntervalSince1970)
        let username = "login_test_\(timestamp)"
        _ = sut.registerUser(username: username, email: "\(username)@test.com", password: "mypassword")
        
        let user = sut.loginUser(username: username, password: "mypassword")
        XCTAssertNotNil(user)
        XCTAssertEqual(user?.username, username)
    }
    
    func testLoginUser_withWrongPassword_returnsNil() {
        let user = sut.loginUser(username: "admin", password: "wrongpassword")
        XCTAssertNil(user, "Login with wrong password should return nil")
    }
    
    func testLoginUser_withNonexistentUser_returnsNil() {
        let user = sut.loginUser(username: "no_such_user_99999", password: "anypassword")
        XCTAssertNil(user)
    }
    
    // MARK: - Favorites Tests
    
    func testToggleFavorite_addsFavorite() {
        // Register test user
        let timestamp = Int(Date().timeIntervalSince1970)
        guard let user = sut.registerUser(username: "fav_test_\(timestamp)",
                                          email: "fav_\(timestamp)@test.com",
                                          password: "pass123") else {
            XCTFail("Failed to register user")
            return
        }
        
        let products = sut.fetchAllProducts()
        guard let firstProduct = products.first else {
            XCTFail("No products available")
            return
        }
        
        // Initially not favorite
        XCTAssertFalse(sut.isFavorite(userId: user.id, productId: firstProduct.id))
        
        // Toggle to add
        let result = sut.toggleFavorite(userId: user.id, productId: firstProduct.id)
        XCTAssertTrue(result, "toggleFavorite should return true when adding")
        XCTAssertTrue(sut.isFavorite(userId: user.id, productId: firstProduct.id))
    }
    
    func testToggleFavorite_removesFavorite() {
        let timestamp = Int(Date().timeIntervalSince1970)
        guard let user = sut.registerUser(username: "fav_rem_\(timestamp)",
                                          email: "fav_rem_\(timestamp)@test.com",
                                          password: "pass123") else { return }
        let products = sut.fetchAllProducts()
        guard let firstProduct = products.first else { return }
        
        _ = sut.toggleFavorite(userId: user.id, productId: firstProduct.id) // add
        let result = sut.toggleFavorite(userId: user.id, productId: firstProduct.id) // remove
        
        XCTAssertFalse(result, "toggleFavorite should return false when removing")
        XCTAssertFalse(sut.isFavorite(userId: user.id, productId: firstProduct.id))
    }
}
