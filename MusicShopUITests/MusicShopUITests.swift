import XCTest

final class MusicShopUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        // Сбрасываем сессию + устанавливаем русский язык
        app.launchArguments = [
            "-AppleLanguages", "(ru)",
            "-AppleLocale", "ru_RU",
            "UI_TESTING"          // флаг для сброса UserDefaults
        ]
        // Сбрасываем UserDefaults через launchEnvironment
        app.launchEnvironment = ["RESET_USER_DEFAULTS": "1"]
        app.launch()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    // MARK: - Login Screen Tests

    func testLoginScreen_isDisplayed_onLaunch() {
        let usernameField = app.textFields["usernameField"]
        XCTAssertTrue(usernameField.waitForExistence(timeout: 5),
            "usernameField not found — app might be showing catalog instead of login")

        let passwordField = app.secureTextFields["passwordField"]
        XCTAssertTrue(passwordField.exists)

        let loginButton = app.buttons["loginButton"]
        XCTAssertTrue(loginButton.exists)
    }

    func testLoginScreen_showsError_onEmptyFields() {
        let loginButton = app.buttons["loginButton"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
        loginButton.tap()

        XCTAssertTrue(app.textFields["usernameField"].waitForExistence(timeout: 3),
            "Should still be on login screen after empty submit")
    }

    func testLoginScreen_navigatesTo_registerScreen() {
        let goToRegisterButton = app.buttons["goToRegisterButton"]
        XCTAssertTrue(goToRegisterButton.waitForExistence(timeout: 5),
            "goToRegisterButton not found on login screen")
        goToRegisterButton.tap()

        let regUsernameField = app.textFields["registerUsernameField"]
        XCTAssertTrue(regUsernameField.waitForExistence(timeout: 5),
            "Should navigate to register screen")
    }

    func testRegisterScreen_showsAllFields() {
        navigateToRegister()

        XCTAssertTrue(app.textFields["registerUsernameField"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.textFields["registerEmailField"].exists)
        XCTAssertTrue(app.secureTextFields["registerPasswordField"].exists)
        XCTAssertTrue(app.secureTextFields["registerConfirmPasswordField"].exists)
        XCTAssertTrue(app.buttons["registerButton"].exists)
    }

    func testLogin_withAdminCredentials_showsTabBar() {
        loginAs(username: "admin", password: "admin123")
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 10),
            "Tab bar should appear after successful login")
    }

    func testCatalog_favoritesButton_isVisible() {
        loginAs(username: "admin", password: "admin123")
        guard app.tabBars.firstMatch.waitForExistence(timeout: 10) else {
            XCTFail("Tab bar not found"); return
        }
        let favButton = app.buttons["favoritesButton"]
        XCTAssertTrue(favButton.waitForExistence(timeout: 5),
            "Favorites button should be visible in catalog")
    }

    func testSearch_fieldAcceptsInput() {
        loginAs(username: "admin", password: "admin123")
        guard app.tabBars.firstMatch.waitForExistence(timeout: 10) else {
            XCTFail("Tab bar not found"); return
        }
        app.tabBars.buttons.element(boundBy: 1).tap()

        let searchField = app.textFields["searchField"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("Rock")
        XCTAssertEqual(searchField.value as? String, "Rock")
    }

    func testProfile_logoutButton_isVisible() {
        loginAs(username: "admin", password: "admin123")
        guard app.tabBars.firstMatch.waitForExistence(timeout: 10) else {
            XCTFail("Tab bar not found"); return
        }
        app.tabBars.buttons.element(boundBy: 3).tap()
        XCTAssertTrue(app.buttons["logoutButton"].waitForExistence(timeout: 5),
            "Logout button should be visible in profile")
    }

    func testProfile_logout_returnsToLogin() {
        loginAs(username: "admin", password: "admin123")
        guard app.tabBars.firstMatch.waitForExistence(timeout: 10) else {
            XCTFail("Tab bar not found after login"); return
        }
        app.tabBars.buttons.element(boundBy: 3).tap()

        let logoutButton = app.buttons["logoutButton"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 5))
        logoutButton.tap()

        let confirmButton = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'Выйти' OR label CONTAINS[c] 'Sign Out'")
        ).firstMatch
        if confirmButton.waitForExistence(timeout: 3) {
            confirmButton.tap()
        }

        XCTAssertTrue(app.textFields["usernameField"].waitForExistence(timeout: 5),
            "Should return to login screen after logout")
    }

    func testMap_nearestStoreButton_isVisible() {
        loginAs(username: "admin", password: "admin123")
        guard app.tabBars.firstMatch.waitForExistence(timeout: 10) else {
            XCTFail("Tab bar not found"); return
        }
        app.tabBars.buttons.element(boundBy: 2).tap()
        XCTAssertTrue(app.buttons["nearestStoreButton"].waitForExistence(timeout: 5),
            "Nearest store button should be visible on map screen")
    }

    // MARK: - Helpers

    private func loginAs(username: String, password: String) {
        let usernameField = app.textFields["usernameField"]
        guard usernameField.waitForExistence(timeout: 8) else { return }
        usernameField.tap()
        usernameField.typeText(username)

        let passwordField = app.secureTextFields["passwordField"]
        passwordField.tap()
        passwordField.typeText(password)

        let loginButton = app.buttons["loginButton"]
        if loginButton.waitForExistence(timeout: 5) {
            loginButton.tap()
        }
    }

    private func navigateToRegister() {
        let goToRegister = app.buttons["goToRegisterButton"]
        if goToRegister.waitForExistence(timeout: 5) {
            goToRegister.tap()
        }
    }
}
