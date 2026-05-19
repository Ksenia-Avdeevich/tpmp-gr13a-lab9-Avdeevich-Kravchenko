import XCTest
@testable import MusicShop

// MARK: - UserDefaults Service Tests

final class UserDefaultsServiceTests: XCTestCase {
    
    var sut: UserDefaultsService!
    
    override func setUp() {
        super.setUp()
        sut = UserDefaultsService.shared
        sut.clearSession()
    }
    
    override func tearDown() {
        sut.clearSession()
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Session Tests
    
    func testInitialState_noSessionActive() {
        XCTAssertFalse(sut.isSessionActive)
        XCTAssertNil(sut.loggedInUserId)
        XCTAssertNil(sut.loggedInUsername)
    }
    
    func testSaveSession_persistsUserData() {
        let user = User(id: 42, username: "testuser", email: "test@test.com",
                        passwordHash: "hash", role: .buyer)
        sut.saveSession(user: user)
        
        XCTAssertEqual(sut.loggedInUserId, 42)
        XCTAssertEqual(sut.loggedInUsername, "testuser")
        XCTAssertEqual(sut.loggedInUserRole, "buyer")
        XCTAssertTrue(sut.isSessionActive)
    }
    
    func testSaveSession_manager_persistsRole() {
        let user = User(id: 1, username: "admin", email: "admin@test.com",
                        passwordHash: "hash", role: .manager)
        sut.saveSession(user: user)
        
        XCTAssertEqual(sut.loggedInUserRole, "manager")
    }
    
    func testClearSession_removesAllSessionData() {
        let user = User(id: 5, username: "user5", email: "u5@test.com",
                        passwordHash: "hash", role: .buyer)
        sut.saveSession(user: user)
        sut.clearSession()
        
        XCTAssertNil(sut.loggedInUserId)
        XCTAssertNil(sut.loggedInUsername)
        XCTAssertNil(sut.loggedInUserRole)
        XCTAssertFalse(sut.isSessionActive)
    }
    
    // MARK: - Preferences Tests
    
    func testSelectedLanguage_defaultIsRu() {
        // Clear any previous setting
        UserDefaults.standard.removeObject(forKey: "selectedLanguage")
        XCTAssertEqual(sut.selectedLanguage, "ru")
    }
    
    func testSelectedLanguage_canBeChanged() {
        sut.selectedLanguage = "en"
        XCTAssertEqual(sut.selectedLanguage, "en")
        sut.selectedLanguage = "be"
        XCTAssertEqual(sut.selectedLanguage, "be")
    }
    
    func testLastSearchQuery_canBeSaved() {
        sut.lastSearchQuery = "Pink Floyd"
        XCTAssertEqual(sut.lastSearchQuery, "Pink Floyd")
    }
    
    func testOnboardingCompleted_defaultFalse() {
        UserDefaults.standard.removeObject(forKey: "onboardingCompleted")
        XCTAssertFalse(sut.onboardingCompleted)
    }
    
    func testOnboardingCompleted_canBeSetToTrue() {
        sut.onboardingCompleted = true
        XCTAssertTrue(sut.onboardingCompleted)
    }
    
    func testIsDarkMode_canBeToggled() {
        sut.isDarkMode = true
        XCTAssertTrue(sut.isDarkMode)
        sut.isDarkMode = false
        XCTAssertFalse(sut.isDarkMode)
    }
}
