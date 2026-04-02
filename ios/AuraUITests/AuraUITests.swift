import XCTest

final class AuraUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments += ["--uitesting"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Home screen

    func testHomeScreenLoads() {
        // The "Today" tab should be visible on launch.
        let todayTab = app.tabBars.buttons["Today"]
        XCTAssertTrue(todayTab.exists, "Today tab should be present")
        XCTAssertTrue(todayTab.isSelected, "Today tab should be selected by default")
    }

    func testQuickLogButtonExists() {
        let logButton = app.buttons["quickLogButton"]
        XCTAssertTrue(logButton.waitForExistence(timeout: 5),
                      "Quick log FAB should be visible on the home screen")
    }

    func testQuickLogButtonOpensSheet() {
        let logButton = app.buttons["quickLogButton"]
        XCTAssertTrue(logButton.waitForExistence(timeout: 5))
        logButton.tap()
        // The sheet title should appear
        let sheetTitle = app.staticTexts["What would you like to log?"]
        XCTAssertTrue(sheetTitle.waitForExistence(timeout: 3),
                      "Quick log sheet should appear after tapping the FAB")
    }

    // MARK: - Tab navigation

    func testHistoryTabExists() {
        let historyTab = app.tabBars.buttons["History"]
        XCTAssertTrue(historyTab.exists)
        historyTab.tap()
        let nav = app.navigationBars["History"]
        XCTAssertTrue(nav.waitForExistence(timeout: 3))
    }

    func testSettingsTabExists() {
        let settingsTab = app.tabBars.buttons["Settings"]
        XCTAssertTrue(settingsTab.exists)
        settingsTab.tap()
        let nav = app.navigationBars["Settings"]
        XCTAssertTrue(nav.waitForExistence(timeout: 3))
    }

    // MARK: - Quick log categories

    func testQuickLogShowsCategoryButtons() {
        app.buttons["quickLogButton"].tap()
        let categories = ["Stress", "Sleep", "Migraine", "Medication", "Activity", "Food", "Note"]
        for name in categories {
            XCTAssertTrue(
                app.buttons[name].waitForExistence(timeout: 3),
                "Category button '\(name)' should exist in QuickLogView"
            )
        }
    }

    func testQuickLogCancelDismissesSheet() {
        app.buttons["quickLogButton"].tap()
        let cancel = app.buttons["Cancel"]
        XCTAssertTrue(cancel.waitForExistence(timeout: 3))
        cancel.tap()
        XCTAssertFalse(
            app.staticTexts["What would you like to log?"].exists,
            "Sheet should be dismissed after tapping Cancel"
        )
    }
}
