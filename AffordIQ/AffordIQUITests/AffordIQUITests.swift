//
//  AffordIQUITests.swift
//  AffordIQUITests
//
//  Created by Simon Lawrence on 19/10/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import XCTest

class AffordIQUITests: XCTestCase {
    var application: XCUIApplication!
    var springboard: XCUIApplication!

    var navigator: AffordIQNavigator!

    override func setUpWithError() throws {
        try super.setUpWithError()

        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        createAndLaunchApplication()
        navigator = AffordIQNavigator(application: application, springboard: springboard, test: self)
    }

    func createAndLaunchApplication() {
        let newApplication = XCUIApplication()
        newApplication.launchArguments += ["-AppleLocale", "en_GB"]
        newApplication.launchEnvironment["MOCKING"] = "true"
        newApplication.launchEnvironment["DELAY_SECONDS"] = "0"
        newApplication.launchEnvironment["CLEARMOCKEDDATA"] = "true"
        newApplication.launchEnvironment["DISABLEBLURANIMATIONS"] = "true"
        newApplication.launchEnvironment["DISABLEALLANIMATIONS"] = "true"
        newApplication.launch()

        application = newApplication
        springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    }

    func testLogin() throws {
        navigator.login()
        navigator.goTo(dashboardPage: .home)
    }

    func testCreateUser() throws {
        navigator.createUser()
        navigator.login()
//    navigator.goTo(dashboardPage: .accounts)
    }

    func testLinkAccounts() throws {
        navigator.login()
        navigator.onboardAccounts(deselectThenSelect: true)
        navigator.renewAccountPermissions()
        navigator.disconnectAccount()
    }

    func testAffordabilityAndPropertySearch() throws {
        navigator.login()
        navigator.onboardAccounts()
        navigator.setupAffordability(outsideCapital: 45000.00,
                                     outsideCapitalDescription: "From Mummy and Daddy",
                                     adjustedIncome: 62000.00)
        navigator.searchProperties(searchText: "G12") { [weak self] autocompleteCell in

            autocompleteCell.tap()

            self?.openPropertySearchResult()
        }

        navigator.goTo(dashboardPage: .affordability)
        navigator.selectCell(identifier: AffordIQNavigator.AffordabilityPage.spending)
        navigator.waitForView(identifier: AffordIQNavigator.RepaymentGoalSavingsPage.page)
        navigator.goBack()
        navigator.goTo(dashboardPage: .goals)
        navigator.waitForView(identifier: AffordIQNavigator.DashboardPropertyGoalPage.page)
        navigator.tapButton(identifier: AffordIQNavigator.DashboardPropertyGoalPage.delete)
        if let alert = navigator.waitForSheetOrAlert() {
            _ = navigator.acceptSheetOrAlert(sheetOrAlert: alert)
        }
        navigator.waitForView(identifier: AffordIQNavigator.PropertyPage.page)
    }

    func filterProperties(affordable: Bool, minimumBedrooms: Int, performAction: Bool) {
        navigator.waitForView(identifier: AffordIQNavigator.PropertySearchResultsPage.page)

        navigator.filterProperties(affordable: affordable, minimumBedrooms: minimumBedrooms)
        navigator.waitForView(identifier: AffordIQNavigator.PropertySearchResultsPage.page)

        if performAction {
            navigator.selectCell(identifier: AffordIQNavigator.PropertySearchResultsPage.propertyCell)

            if let sheet = navigator.waitForSheetOrAlert(),
               navigator.acceptSheetOrAlert(sheetOrAlert: sheet, index: 0) {
                // Success
            }
        }
    }

    func openPropertySearchResult() {
        // Open property details
        navigator.waitForView(identifier: AffordIQNavigator.PropertySearchResultsPage.page)
        navigator.waitForView(identifier: AffordIQNavigator.PropertySearchResultsPage.propertyCell, in: application.cells)
        navigator.waitForView(identifier: AffordIQNavigator.PropertySearchResultsPage.details, in: application.buttons)
        application.buttons[AffordIQNavigator.PropertySearchResultsPage.details.rawValue].firstMatch.tap()
        if let sheet = navigator.waitForSheetOrAlert(),
           navigator.acceptSheetOrAlert(sheetOrAlert: sheet) {
            navigator.waitForView(identifier: AffordIQNavigator.PropertyDetailsPage.page)

            // TODO: Localize
            let doneIdentifier = "Done"
            navigator.waitForView(identifier: doneIdentifier, in: application.buttons)
            application.buttons[doneIdentifier].tap()
        }

        // Filter so there are no matching properties
        filterProperties(affordable: true, minimumBedrooms: 10, performAction: false)
        navigator.waitForView(identifier: "PropertyNoResults", in: application.cells)

        // Choose an affordable property to start the mortgage process
        filterProperties(affordable: true, minimumBedrooms: 3, performAction: true)
        startMortgageProcess()

        // Choose an unaffordable property to set the mortgage goal - this will probably change in future
        filterProperties(affordable: false, minimumBedrooms: 3, performAction: true)
        setPropertyGoal()
    }

    func startMortgageProcess() {
        navigator.waitForView(identifier: AffordIQNavigator.PersonalDetailsPage.page)

        navigator.selectDatePicker(value: "4", index: 0, in: AffordIQNavigator.PersonalDetailsPage.dateOfBirth)
        navigator.selectDatePicker(value: "July", index: 1, activate: false, in: AffordIQNavigator.PersonalDetailsPage.dateOfBirth)
        navigator.selectDatePicker(value: "1971", index: 2, activate: false, in: AffordIQNavigator.PersonalDetailsPage.dateOfBirth)

        navigator.scrollTo(identifier: AffordIQNavigator.PersonalDetailsPage.employmentStatus, in: application.textFields)
        navigator.selectPicker(value: "Employed", in: AffordIQNavigator.PersonalDetailsPage.employmentStatus)
        navigator.scrollTo(identifier: AffordIQNavigator.PersonalDetailsPage.occupation, in: application.textFields)
        navigator.type("Self-facilitating Media Node", in: AffordIQNavigator.PersonalDetailsPage.occupation)
        navigator.selectPicker(value: "1", in: AffordIQNavigator.PersonalDetailsPage.numberOfDependents)
        navigator.selectPicker(value: "12", in: AffordIQNavigator.PersonalDetailsPage.age)
        navigator.scrollTo(identifier: AffordIQNavigator.PersonalDetailsPage.submit, in: application.buttons)
        navigator.tapButton(identifier: AffordIQNavigator.PersonalDetailsPage.submit)
        navigator.waitForView(identifier: AffordIQNavigator.DebtDisclosurePage.page)
        navigator.type("25000", in: AffordIQNavigator.DebtDisclosurePage.totalDebts)
        navigator.selectPicker(value: "Yes", in: AffordIQNavigator.DebtDisclosurePage.anyDebtDefaults)
        navigator.selectPicker(value: "2 years ago", in: AffordIQNavigator.DebtDisclosurePage.howLongAgo)
        navigator.scrollTo(identifier: AffordIQNavigator.DebtDisclosurePage.debtDefaultNotes, in: application.textFields)
        navigator.type("It wasn't my fault", in: AffordIQNavigator.DebtDisclosurePage.debtDefaultNotes)
        navigator.selectPicker(value: "Yes", in: AffordIQNavigator.DebtDisclosurePage.anyCourtJudgements)
        navigator.scrollTo(identifier: AffordIQNavigator.DebtDisclosurePage.courtJudgementNotes, in: application.textFields)
        navigator.type("It wasn't my fault", in: AffordIQNavigator.DebtDisclosurePage.courtJudgementNotes)
        navigator.scrollTo(identifier: AffordIQNavigator.DebtDisclosurePage.submit, in: application.buttons)
        navigator.tapButton(identifier: AffordIQNavigator.DebtDisclosurePage.submit)
    }

    func setPropertyGoal() {
        navigator.waitForView(identifier: AffordIQNavigator.PropertyGoalPage.page)

        for _ in 1 ... 3 {
            application.collectionViews.firstMatch.swipeLeft()
        }

        navigator.tapButton(identifier: AffordIQNavigator.PropertyGoalPage.next)

        navigator.waitForView(identifier: AffordIQNavigator.PropertyGoalSavingsPage.page)

        application.sliders[AffordIQNavigator.PropertyGoalSavingsPage.loanToValue.rawValue].adjust(toNormalizedSliderPosition: 0.0)
        application.sliders[AffordIQNavigator.PropertyGoalSavingsPage.loanToValue.rawValue].adjust(toNormalizedSliderPosition: 1.0)
        application.sliders[AffordIQNavigator.PropertyGoalSavingsPage.loanToValue.rawValue].adjust(toNormalizedSliderPosition: 0.2)

        navigator.tapButton(identifier: AffordIQNavigator.PropertyGoalSavingsPage.next)
        navigator.waitForView(identifier: AffordIQNavigator.PropertyGoalSavingsPage.proportion, in: application.sliders)

        application.sliders[AffordIQNavigator.PropertyGoalSavingsPage.proportion.rawValue].adjust(toNormalizedSliderPosition: 0.0)
        application.sliders[AffordIQNavigator.PropertyGoalSavingsPage.proportion.rawValue].adjust(toNormalizedSliderPosition: 1.0)
        application.sliders[AffordIQNavigator.PropertyGoalSavingsPage.proportion.rawValue].adjust(toNormalizedSliderPosition: 0.5)

        navigator.tapButton(identifier: AffordIQNavigator.PropertyGoalSavingsPage.save)

        navigator.waitForView(identifier: AffordIQNavigator.PropertyGoalCompletePage.page)
        navigator.tapButton(identifier: AffordIQNavigator.PropertyGoalCompletePage.spendingTargets)
        setSavingsGoal()

        navigator.waitForView(identifier: AffordIQNavigator.PropertyGoalReviewPage.page)
        navigator.tapButton(identifier: AffordIQNavigator.PropertyGoalReviewPage.done)

        navigator.waitForView(identifier: AffordIQNavigator.DashboardPropertyGoalPage.page)
    }

    func setSavingsGoal() {
        navigator.waitForView(identifier: AffordIQNavigator.SavingsGoalPage.page)
        let table = application.tables.element(boundBy: application.tables.count - 1)
        table.cells.element(boundBy: 0).tap()
        let stepper = application.steppers.element(boundBy: 0)
        let decrement = stepper.buttons.matching(identifier: "Decrement").firstMatch

        (1 ..< 10).forEach { _ in
            decrement.tap()
        }
        navigator.tapButton(identifier: AffordIQNavigator.SavingsGoalPage.setAmount)
        navigator.tapButton(identifier: AffordIQNavigator.SavingsGoalPage.save)
    }

    func testSettings() throws {
        navigator.login()
        navigator.goTo(dashboardPage: .home)
        navigator.waitForView(identifier: AffordIQNavigator.HomePage.page)
        navigator.tapButton(identifier: AffordIQNavigator.HomePage.settings)
        navigator.waitForView(identifier: AffordIQNavigator.SettingsPage.page)
        navigator.tapButton(identifier: AffordIQNavigator.SettingsPage.acknowlegements)
        navigator.waitForView(identifier: AffordIQNavigator.AcknowledgementsPage.page)
        navigator.goBack()
        navigator.waitForView(identifier: AffordIQNavigator.SettingsPage.page)
        navigator.tapButton(identifier: AffordIQNavigator.SettingsPage.logout)
        navigator.waitForView(identifier: AffordIQNavigator.LoginPage.page)
    }

    func testTransactions() throws {
        navigator.login()
        navigator.onboardAccounts()
        navigator.goTo(dashboardPage: .home)
        navigator.waitForView(identifier: AffordIQNavigator.HomePage.page)
        navigator.selectCell(identifier: "SPENDING")
        navigator.selectCell(identifier: "Groceries")
        navigator.waitForView(identifier: AffordIQNavigator.TransactionsPage.page)
        navigator.selectCell(identifier: "AMAZON PRIME")
        navigator.goBack()
        navigator.waitForView(identifier: AffordIQNavigator.HomePage.page)
        navigator.selectCell(identifier: "Gambling")
        navigator.waitForView(identifier: AffordIQNavigator.TransactionsPage.page)
        navigator.selectCell(identifier: "MORSES CLUB LTD")
        navigator.goBack()
        navigator.waitForView(identifier: AffordIQNavigator.HomePage.page)

        navigator.swipe(identifier: "Overlay.GestureView", direction: .down)
        navigator.waitForView(identifier: AffordIQNavigator.HomePage.page)
    }
}
