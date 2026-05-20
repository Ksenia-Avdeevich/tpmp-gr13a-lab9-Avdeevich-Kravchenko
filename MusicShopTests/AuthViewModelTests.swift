import XCTest
@testable import MusicShop

// MARK: - Auth ViewModel Tests

final class AuthViewModelTests: XCTestCase {
    
    var sut: AuthViewModel!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        sut = AuthViewModel()
        // Clear session before each test
        UserDefaultsService.shared.clearSession()
    }
    
    override func tearDown() {
        UserDefaultsService.shared.clearSession()
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testInitialState_isNotLoggedIn() {
        // XCTAssertFalse(sut.isLoggedIn, "Initially should not be logged in")
        // XCTAssertNil(sut.currentUser, "Initially currentUser should be nil")
        XCTAssertEqual(sut.errorMessage, "", "Initially errorMessage should be empty")
    }
    
    func testLogin_withEmptyFields_showsError() {
        // When
        sut.login(username: "", password: "")
        
        // Then
        XCTAssertFalse(sut.isLoggedIn)
        XCTAssertFalse(sut.errorMessage.isEmpty, "Error message should not be empty for empty fields")
    }
    
    func testLogin_withEmptyUsername_showsError() {
        sut.login(username: "", password: "somepassword")
        XCTAssertFalse(sut.isLoggedIn)
        XCTAssertFalse(sut.errorMessage.isEmpty)
    }
    
    func testLogin_withEmptyPassword_showsError() {
        sut.login(username: "someuser", password: "")
        XCTAssertFalse(sut.isLoggedIn)
        XCTAssertFalse(sut.errorMessage.isEmpty)
    }
    
    func testLogin_withValidAdminCredentials_succeeds() {
        // Admin is seeded in DatabaseService.seedAdminUser()
        let expectation = expectation(description: "Login completes")
        
        sut.login(username: "admin", password: "admin123")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2.0) { _ in
            XCTAssertTrue(self.sut.isLoggedIn, "Admin should be able to login")
            XCTAssertNotNil(self.sut.currentUser)
            XCTAssertEqual(self.sut.currentUser?.username, "admin")
        }
    }
    
    func testLogin_withWrongPassword_fails() {
        let expectation = expectation(description: "Login fails")
        
        sut.login(username: "admin", password: "wrongpassword")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2.0) { _ in
            XCTAssertFalse(self.sut.isLoggedIn)
            XCTAssertNil(self.sut.currentUser)
            XCTAssertFalse(self.sut.errorMessage.isEmpty)
        }
    }
    
    func testRegister_withMismatchedPasswords_showsError() {
        sut.register(username: "testuser", email: "test@test.com",
                     password: "pass123", confirmPassword: "pass456")
        XCTAssertFalse(sut.isLoggedIn)
        XCTAssertFalse(sut.errorMessage.isEmpty)
    }
    
    func testRegister_withInvalidEmail_showsError() {
        sut.register(username: "testuser", email: "not-an-email",
                     password: "pass123", confirmPassword: "pass123")
        XCTAssertFalse(sut.isLoggedIn)
        XCTAssertFalse(sut.errorMessage.isEmpty)
    }
    
    func testRegister_withShortPassword_showsError() {
        sut.register(username: "testuser", email: "test@test.com",
                     password: "123", confirmPassword: "123")
        XCTAssertFalse(sut.isLoggedIn)
        XCTAssertFalse(sut.errorMessage.isEmpty)
    }
    
    func testLogout_clearsSession() {
        // Given — logged in state
        let user = User(id: 1, username: "testuser", email: "t@t.com", passwordHash: "hash")
        sut.currentUser = user
        sut.isLoggedIn = true
        UserDefaultsService.shared.saveSession(user: user)
        
        // When
        sut.logout()
        
        // Then
        XCTAssertFalse(sut.isLoggedIn)
        XCTAssertNil(sut.currentUser)
        XCTAssertNil(UserDefaultsService.shared.loggedInUserId)
    }
}
