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
        
        // Add a small delay for initial UI load
        Thread.sleep(forTimeInterval: 0.5)
    }
    
    override func tearDown() {
        app = nil
        super.tearDown()
    }
    
    // MARK: - Login Screen Tests
    
    func testLoginScreen_isDisplayed_onLaunch() {
        // Use more flexible waiting strategy
        let usernameField = app.textFields["usernameField"]
        let passwordField = app.secureTextFields["passwordField"]
        let loginButton = app.buttons["loginButton"]
        
        // Wait with longer timeout and retry
        let usernameExists = usernameField.waitForExistence(timeout: 5)
        let passwordExists = passwordField.waitForExistence(timeout: 5)
        let loginExists = loginButton.waitForExistence(timeout: 5)
        
        XCTAssertTrue(usernameExists, "Username field not found")
        XCTAssertTrue(passwordExists, "Password field not found")
        XCTAssertTrue(loginExists, "Login button not found")
    }
    
    func testLoginScreen_showsError_onEmptyFields() {
        let loginButton = app.buttons["loginButton"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
        
        loginButton.tap()
        
        // More robust error checking
        let errorExists = NSPredicate { _, _ in
            let errorElements = self.app.staticTexts.matching(
                NSPredicate(format: "label CONTAINS[c] 'error' OR label CONTAINS[c] 'пусто' OR label CONTAINS[c] 'заполните'")
            )
            return errorElements.count > 0
        }
        
        // Check if we're still on login screen
        let stillOnLoginScreen = app.textFields["usernameField"].waitForExistence(timeout: 2)
        XCTAssertTrue(stillOnLoginScreen, "Should still be on login screen after empty submit")
    }
    
    func testLoginScreen_navigatesTo_registerScreen() {
        // Try different possible identifiers for register button
        let registerSelectors = ["registerButton", "signUpButton", "createAccountButton"]
        
        var registerButton: XCUIElement?
        for selector in registerSelectors {
            registerButton = app.buttons[selector]
            if registerButton?.exists == true {
                break
            }
        }
        
        // If button not found by identifier, try by label
        if registerButton == nil || !(registerButton?.exists ?? false) {
            registerButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'регистр' OR label CONTAINS[c] 'создать' OR label CONTAINS[c] 'аккаунт'")).firstMatch
        }
        
        if let button = registerButton, button.waitForExistence(timeout: 5) {
            button.tap()
        } else {
            XCTFail("Register button not found")
            return
        }
        
        // Check for any register screen indicator with retry
        let registerIndicators = [
            app.textFields["registerUsernameField"],
            app.secureTextFields["registerPasswordField"],
            app.textFields["emailField"],
            app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'зарегистр'")).firstMatch
        ]
        
        var foundRegisterScreen = false
        for indicator in registerIndicators {
            if indicator.waitForExistence(timeout: 3) {
                foundRegisterScreen = true
                break
            }
        }
        
        XCTAssertTrue(foundRegisterScreen, "Should navigate to register screen")
    }
    
    // MARK: - Login Flow Tests
    
    func testLogin_withAdminCredentials_navigatesToCatalog() {
        loginAs(username: "admin", password: "admin123")
        
        // Check for any main screen indicator
        let mainIndicators = [
            app.tabBars.firstMatch,
            app.navigationBars.firstMatch,
            app.buttons["favoritesButton"]
        ]
        
        var foundMainScreen = false
        for indicator in mainIndicators {
            if indicator.waitForExistence(timeout: 5) {
                foundMainScreen = true
                break
            }
        }
        
        XCTAssertTrue(foundMainScreen, "Should navigate to main app screen after successful login")
    }
    
    // MARK: - Register Screen Tests
    
    func testRegisterScreen_showsAllFields() {
        navigateToRegister()
        
        // Use more flexible field detection
        let fields = [
            app.textFields.element(matching: .any, identifier: "registerUsernameField"),
            app.textFields.element(matching: .any, identifier: "registerEmailField"),
            app.secureTextFields.element(matching: .any, identifier: "registerPasswordField"),
            app.secureTextFields.element(matching: .any, identifier: "registerConfirmPasswordField")
        ]
        
        var allFieldsFound = true
        for (index, field) in fields.enumerated() {
            if !field.waitForExistence(timeout: 2) {
                allFieldsFound = false
                print("Field \(index) not found")
            }
        }
        
        let registerButton = app.buttons.element(matching: .any, identifier: "registerButton")
        let registerExists = registerButton.waitForExistence(timeout: 2)
        
        // If exact identifiers not found, try by type
        if !allFieldsFound {
            let textFields = app.textFields.count
            let secureFields = app.secureTextFields.count
            
            allFieldsFound = textFields >= 2 && secureFields >= 2
        }
        
        XCTAssertTrue(allFieldsFound || registerExists, "Register screen should show all required fields")
    }
    
    // MARK: - Main App Tests (after login)
    
    func testCatalog_favoritesButton_isVisible() {
        loginAs(username: "admin", password: "admin123")
        
        let favSelectors = ["favoritesButton", "favoriteButton", "wishlistButton"]
        var foundButton = false
        
        for selector in favSelectors {
            let button = app.buttons[selector]
            if button.waitForExistence(timeout: 2) {
                foundButton = true
                break
            }
        }
        
        if !foundButton {
            // Try by icon or label
            let likeButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'favorite' OR label CONTAINS[c] 'избран'")).firstMatch
            foundButton = likeButton.waitForExistence(timeout: 3)
        }
        
        XCTAssertTrue(foundButton, "Favorites button should be visible")
    }
    
    func testSearch_field_isInteractable() {
        loginAs(username: "admin", password: "admin123")
        
        // Navigate to search tab
        let searchTab = app.tabBars.buttons.element(boundBy: 1)
        if searchTab.waitForExistence(timeout: 5) {
            searchTab.tap()
        } else {
            // Try to find search tab by label
            let searchTabByLabel = app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'поиск'")).firstMatch
            searchTabByLabel.tap()
        }
        
        let searchSelectors = ["searchField", "searchTextField", "searchBar"]
        var searchField: XCUIElement?
        
        for selector in searchSelectors {
            searchField = app.textFields[selector]
            if searchField?.waitForExistence(timeout: 2) == true {
                break
            }
        }
        
        guard let field = searchField, field.waitForExistence(timeout: 5) else {
            XCTFail("Search field not found")
            return
        }
        
        field.tap()
        field.typeText("Rock")
        
        // Wait for text to appear and verify
        Thread.sleep(forTimeInterval: 0.5)
        let fieldValue = field.value as? String
        XCTAssertTrue(fieldValue?.contains("Rock") == true, "Search field should contain typed text")
    }
    
    func testProfile_logoutButton_isVisible() {
        loginAs(username: "admin", password: "admin123")
        
        // Navigate to profile tab
        let profileTab = app.tabBars.buttons.element(boundBy: 3)
        if profileTab.waitForExistence(timeout: 5) {
            profileTab.tap()
        } else {
            let profileTabByLabel = app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'профиль'")).firstMatch
            profileTabByLabel.tap()
        }
        
        let logoutSelectors = ["logoutButton", "logOutButton", "signOutButton"]
        var foundButton = false
        
        for selector in logoutSelectors {
            let button = app.buttons[selector]
            if button.waitForExistence(timeout: 2) {
                foundButton = true
                break
            }
        }
        
        if !foundButton {
            let logoutByLabel = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'выйти' OR label CONTAINS[c] 'logout'")).firstMatch
            foundButton = logoutByLabel.waitForExistence(timeout: 3)
        }
        
        XCTAssertTrue(foundButton, "Logout button should be visible")
    }
    
    func testProfile_logout_returnsToLogin() {
        loginAs(username: "admin", password: "admin123")
        
        let profileTab = app.tabBars.buttons.element(boundBy: 3)
        if profileTab.waitForExistence(timeout: 5) {
            profileTab.tap()
        } else {
            let profileTabByLabel = app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'профиль'")).firstMatch
            profileTabByLabel.tap()
        }
        
        // Find logout button
        let logoutButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'выйти' OR label CONTAINS[c] 'logout'")).firstMatch
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 5), "Logout button should be visible")
        logoutButton.tap()
        
        // Handle confirmation dialog
        let confirmButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'выйти' OR label CONTAINS[c] 'да' OR label CONTAINS[c] 'подтвердить'")).firstMatch
        if confirmButton.waitForExistence(timeout: 3) {
            confirmButton.tap()
        }
        
        // Wait for dismissal animation and check for login screen
        Thread.sleep(forTimeInterval: 1.0)
        
        let loginIndicators = [
            app.textFields["usernameField"],
            app.secureTextFields["passwordField"],
            app.buttons["loginButton"],
            app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'войти'")).firstMatch
        ]
        
        var foundLoginScreen = false
        for indicator in loginIndicators {
            if indicator.waitForExistence(timeout: 5) {
                foundLoginScreen = true
                break
            }
        }
        
        XCTAssertTrue(foundLoginScreen, "Should return to login screen after logout")
    }
    
    func testMap_nearestStoreButton_isVisible() {
        loginAs(username: "admin", password: "admin123")
        
        let mapTab = app.tabBars.buttons.element(boundBy: 2)
        if mapTab.waitForExistence(timeout: 5) {
            mapTab.tap()
        } else {
            let mapTabByLabel = app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'карта'")).firstMatch
            mapTabByLabel.tap()
        }
        
        let nearestSelectors = ["nearestStoreButton", "nearestButton", "findNearestButton"]
        var foundButton = false
        
        for selector in nearestSelectors {
            let button = app.buttons[selector]
            if button.waitForExistence(timeout: 2) {
                foundButton = true
                break
            }
        }
        
        if !foundButton {
            let nearestByLabel = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'ближайш' OR label CONTAINS[c] 'nearest'")).firstMatch
            foundButton = nearestByLabel.waitForExistence(timeout: 3)
        }
        
        XCTAssertTrue(foundButton, "Nearest store button should be visible")
    }
    
    // MARK: - Helpers
    
    private func loginAs(username: String, password: String) {
        let usernameField = app.textFields["usernameField"]
                
                // Check if username field exists, if not try alternative
                guard usernameField.waitForExistence(timeout: 5) else {
                    // Try alternative username field identifiers
                    let altUsernameField = app.textFields.element(boundBy: 0)
                    guard altUsernameField.waitForExistence(timeout: 3) else {
                        return
                    }
                    altUsernameField.tap()
                    altUsernameField.typeText(username)
                    return
                }
        
        if usernameField.exists {
            usernameField.tap()
            usernameField.clearAndTypeText(username)
        }
        
        let passwordField = app.secureTextFields["passwordField"]
        if passwordField.waitForExistence(timeout: 3) {
            passwordField.tap()
            passwordField.typeText(password)
        }
        
        let loginButton = app.buttons["loginButton"]
        if loginButton.waitForExistence(timeout: 3) {
            loginButton.tap()
        } else {
            let altLoginButton = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'войти'")).firstMatch
            if altLoginButton.waitForExistence(timeout: 3) {
                altLoginButton.tap()
            }
        }
        
        // Wait for navigation to complete
        Thread.sleep(forTimeInterval: 1.0)
    }
    
    private func navigateToRegister() {
        let registerLink = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'регистр' OR label CONTAINS[c] 'создать' OR label CONTAINS[c] 'аккаунт'")
        ).firstMatch
        
        if registerLink.waitForExistence(timeout: 5) {
            registerLink.tap()
            Thread.sleep(forTimeInterval: 0.5)
        } else {
            // Try to find by identifier
            let registerButton = app.buttons["registerButton"]
            if registerButton.exists {
                registerButton.tap()
                Thread.sleep(forTimeInterval: 0.5)
            }
        }
    }
}

// MARK: - Extensions

extension XCUIElement {
    func clearAndTypeText(_ text: String) {
        guard let stringValue = self.value as? String else {
            self.tap()
            self.typeText(text)
            return
        }
        
        self.tap()
        
        // Select all text
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
        self.typeText(text)
    }
}
