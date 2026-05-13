import XCTest

final class LingerUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAppLaunches() {
        let app = XCUIApplication()
        app.launchArguments += ["-UITests"]
        app.launch()
        XCTAssertTrue(app.staticTexts["Linger"].waitForExistence(timeout: 5))
    }
}
