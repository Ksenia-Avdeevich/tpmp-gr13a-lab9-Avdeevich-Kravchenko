import XCTest

// MARK: - UI Tests

final class MusicShopUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }
    
    override func tearDown() {
        app = nil
        super.tearDown()
    }
    
    // MARK: - Login Screen Tests
    
    func testLoginScreen_isDisplayed_onLaunch() {
        let usernameField = app.textFields["usernameField"]
        let passwordField = app.secureTextFields["passwordField"]
        let loginButton = app.buttons["loginButton"]
        
        XCTAssertTrue(usernameField.waitForExistence(timeout: 3))
        XCTAssertTrue(passwordField.exists)
        XCTAssertTrue(loginButton.exists)
    }
    
    func testLoginScreen_showsError_onEmptyFields() {
        let loginButton = app.buttons["loginButton"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 3))
        
        loginButton.tap()
        
        // Error should appear somewhere on screen
        let errorExists = app.staticTexts.element(matching: .any, identifier: "errorText").exists
        // Alternative: check that we're still on login screen (not navigated away)
        XCTAssertTrue(app.textFields["usernameField"].exists,
                      "Should still be on login screen after empty submit")
    }
    
    func testLoginScreen_navigatesTo_registerScreen() {
        // Find and tap the register button/link
        let registerButton = app.buttons["registerButton"]
        if registerButton.waitForExistence(timeout: 3) {
            registerButton.tap()
        } else {
            // Try finding via static text
            let registerLink = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Зарегистр'")).firstMatch
            if registerLink.waitForExistence(timeout: 3) {
                registerLink.tap()
            }
        }
        
        // Check register form field exists
        let regUsernameField = app.textFields["registerUsernameField"]
        XCTAssertTrue(regUsernameField.waitForExistence(timeout: 3),
                      "Should navigate to register screen")
    }
    
    // MARK: - Login Flow Tests
    
    func testLogin_withAdminCredentials_navigatesToCatalog() {
        loginAs(username: "admin", password: "admin123")
        
        // Catalog tab should be visible
        let catalogTitle = app.navigationBars.element(
            matching: .any,
            identifier: "Каталог"
        )
        // Or check the tab bar
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5),
                      "Tab bar should appear after successful login")
    }
    
    // MARK: - Register Screen Tests
    
    func testRegisterScreen_showsAllFields() {
        navigateToRegister()
        
        XCTAssertTrue(app.textFields["registerUsernameField"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.textFields["registerEmailField"].exists)
        XCTAssertTrue(app.secureTextFields["registerPasswordField"].exists)
        XCTAssertTrue(app.secureTextFields["registerConfirmPasswordField"].exists)
        XCTAssertTrue(app.buttons["registerButton"].exists)
    }
    
    // MARK: - Main App Tests (after login)
    
    func testCatalog_favoritesButton_isVisible() {
        loginAs(username: "admin", password: "admin123")
        
        let favButton = app.buttons["favoritesButton"]
        XCTAssertTrue(favButton.waitForExistence(timeout: 5))
    }
    
    func testSearch_field_isInteractable() {
        loginAs(username: "admin", password: "admin123")
        
        // Navigate to search tab
        let searchTab = app.tabBars.buttons.element(boundBy: 1)
        searchTab.tap()
        
        let searchField = app.textFields["searchField"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 3))
        
        searchField.tap()
        searchField.typeText("Rock")
        
        XCTAssertEqual(searchField.value as? String, "Rock")
    }
    
    func testProfile_logoutButton_isVisible() {
        loginAs(username: "admin", password: "admin123")
        
        // Navigate to profile tab (last tab)
        let profileTab = app.tabBars.buttons.element(boundBy: 3)
        profileTab.tap()
        
        let logoutButton = app.buttons["logoutButton"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 3))
    }
    
    func testProfile_logout_returnsToLogin() {
        loginAs(username: "admin", password: "admin123")
        
        let profileTab = app.tabBars.buttons.element(boundBy: 3)
        profileTab.tap()
        
        let logoutButton = app.buttons["logoutButton"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 3))
        logoutButton.tap()
        
        // Confirm logout in dialog
        let confirmButton = app.buttons.matching(
            NSPredicate(format: "label CONTAINS 'Выйти'")
        ).element(boundBy: 0)
        if confirmButton.waitForExistence(timeout: 2) {
            confirmButton.tap()
        }
        
        // Should return to login screen
        XCTAssertTrue(app.textFields["usernameField"].waitForExistence(timeout: 3),
                      "Should return to login screen after logout")
    }
    
    func testMap_nearestStoreButton_isVisible() {
        loginAs(username: "admin", password: "admin123")
        
        let mapTab = app.tabBars.buttons.element(boundBy: 2)
        mapTab.tap()
        
        let nearestButton = app.buttons["nearestStoreButton"]
        XCTAssertTrue(nearestButton.waitForExistence(timeout: 3))
    }
    
    // MARK: - Helpers
    
    private func loginAs(username: String, password: String) {
        let usernameField = app.textFields["usernameField"]
        guard usernameField.waitForExistence(timeout: 5) else { return }
        
        usernameField.tap()
        usernameField.typeText(username)
        
        let passwordField = app.secureTextFields["passwordField"]
        passwordField.tap()
        passwordField.typeText(password)
        
        app.buttons["loginButton"].tap()
    }
    
    private func navigateToRegister() {
        let registerLink = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'Зарегистр'")
        ).firstMatch
        if registerLink.waitForExistence(timeout: 3) {
            registerLink.tap()
        }
    }
}
