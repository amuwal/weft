import XCTest

final class LingerUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Welcome copy renders and Begin advances to step 2.
    func testOnboardingAdvancesToRhythmStep() {
        let app = launch(arguments: [])
        let welcomeQuiet = app.staticTexts.containing(NSPredicate(
            format: "label CONTAINS[c] %@",
            "quiet place"
        )).firstMatch
        XCTAssertTrue(welcomeQuiet.waitForExistence(timeout: 6))

        let begin = app.buttons["Begin"]
        XCTAssertTrue(begin.waitForExistence(timeout: 2))
        begin.tap()

        let step2 = app.staticTexts["Step 2 of 2"]
        XCTAssertTrue(step2.waitForExistence(timeout: 3))
    }

    /// Seeded Today shows the prompt and at least one person name.
    func testTodayRendersWithSeededData() {
        let app = launch(arguments: ["--seed", "--onboarding-done"])
        let prompt = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "mind today"))
            .firstMatch
        XCTAssertTrue(prompt.waitForExistence(timeout: 6))
        let sarah = app.staticTexts["Sarah"]
        XCTAssertTrue(sarah.waitForExistence(timeout: 3))
    }

    /// People tab shows grouped section headers from the seeded relationships.
    func testPeopleTabShowsGroupedRelationships() {
        let app = launch(arguments: ["--seed", "--people", "--onboarding-done"])
        XCTAssertTrue(app.staticTexts["People"].waitForExistence(timeout: 6))
        XCTAssertTrue(app.staticTexts["Inner circle"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Close friends"].exists)
        XCTAssertTrue(app.staticTexts["Family"].exists)
    }

    /// Settings sheet opens via the gear icon and shows the iCloud toggle.
    func testSettingsOpensFromLaunchFlag() {
        let app = launch(arguments: ["--seed", "--settings", "--onboarding-done"])
        XCTAssertTrue(app.staticTexts["Settings"].waitForExistence(timeout: 6))
        XCTAssertTrue(app.staticTexts["iCloud sync"].exists)
    }

    /// Paywall renders with both plan rows and the trial CTA.
    func testPaywallOpensFromLaunchFlag() {
        let app = launch(arguments: ["--seed", "--paywall", "--onboarding-done"])
        XCTAssertTrue(app.staticTexts["Linger Premium"].waitForExistence(timeout: 6))
        XCTAssertTrue(app.staticTexts["Yearly"].exists)
        XCTAssertTrue(app.staticTexts["Monthly"].exists)
        XCTAssertTrue(app.buttons["Start free trial"].exists)
    }

    private func launch(arguments: [String]) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += arguments
        app.launch()
        return app
    }
}
