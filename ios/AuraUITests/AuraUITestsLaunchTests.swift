import XCTest

final class AuraUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool { true }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launchArguments += ["--uitesting"]
        app.launch()

        // Take a screenshot of the launch screen for the test report.
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name           = "Launch Screen"
        attachment.lifetime       = .keepAlways
        add(attachment)
    }
}
