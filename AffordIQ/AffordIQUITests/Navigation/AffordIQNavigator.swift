//
//  AffordIQNavigator.swift
//  AffordIQ
//
//  Created by Simon Lawrence on 24/12/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import XCTest

class AffordIQNavigator: NSObject {
    static let defaultTimeout: TimeInterval = 30.0

    let accountIds = ["01-21-31 20000000",
                      "01-21-31 20000001",
                      "01-21-31 10000000",
                      "01-21-31 30000000",
                      "01-21-31 50000000"].shuffled()

    weak var application: XCUIApplication!
    weak var springboard: XCUIApplication!
    weak var test: XCTestCase!

    // If this is false a system dialog will be expected when the authentication session
    // for open banking is started.
    let openBankingEphemeralSession = true

    init(application: XCUIApplication, springboard: XCUIApplication, test: XCTestCase) {
        self.application = application
        self.springboard = springboard
        self.test = test
    }

    func goBack() {
        application.navigationBars.buttons.element(boundBy: 0).tap()
    }

    @discardableResult
    func waitForView(identifier: String, hittable: Bool = false, in query: XCUIElementQuery? = nil, timeout: TimeInterval = AffordIQNavigator.defaultTimeout) -> XCUIElement {
        let query = query ?? application.otherElements
        let element = query[identifier]
        let predicate = hittable ? NSPredicate(format: "isHittable=true") : NSPredicate(format: "exists == true")
        test.expectation(for: predicate, evaluatedWith: element, handler: nil)
        test.waitForExpectations(timeout: timeout, handler: nil)
        return element
    }

    @discardableResult
    func waitForView<T: RawRepresentable>(identifier: T, hittable: Bool = false, in query: XCUIElementQuery? = nil, timeout: TimeInterval = AffordIQNavigator.defaultTimeout) -> XCUIElement where T.RawValue == String {
        return waitForView(identifier: identifier.rawValue, hittable: hittable, in: query, timeout: timeout)
    }

    func tapButton<T: RawRepresentable>(identifier: T, timeout: TimeInterval = AffordIQNavigator.defaultTimeout) where T.RawValue == String {
        waitForView(identifier: identifier, hittable: true, in: application.buttons, timeout: timeout)
        application.buttons[identifier.rawValue].tap()
    }

    func tapBarButton<T: RawRepresentable>(identifier: T, timeout: TimeInterval = AffordIQNavigator.defaultTimeout) where T.RawValue == String {
        waitForView(identifier: identifier, hittable: true, in: application.navigationBars.children(matching: .button), timeout: timeout)
        application.buttons[identifier.rawValue].tap()
    }

    func type<T: RawRepresentable>(_ text: String, in identifier: T, clear: Bool = true, isSecure: Bool = false) where T.RawValue == String {
        let collection = isSecure ? application.secureTextFields : application.textFields

        waitForView(identifier: identifier, hittable: true, in: collection)
        let element = collection[identifier.rawValue]
        element.tap()

        if clear,
           let stringValue = element.value as? String,
           stringValue != element.placeholderValue {
            let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
            element.typeText(deleteString)
        }

        element.typeText(text)
    }

    func search(_ text: String?, shouldReturn: Bool = false) {
        let searchField = application.searchFields.firstMatch

        searchField.tap()
        searchField.typeText(text ?? "")

        if shouldReturn {
            searchField.typeText(XCUIKeyboardKey.return.rawValue)
        }
    }

    func login() {
        waitForView(identifier: LoginPage.page)
        tapButton(identifier: LoginPage.signIn)
        waitForView(identifier: StateLoaderPage.page)
//    waitForView(identifier: DashboardPage.page)
    }

    func searchProperties(searchText: String, completion: @escaping (XCUIElement) -> Void) {
//    goTo(dashboardPage: .property)
        waitForView(identifier: PropertyPage.page)
        search(searchText, shouldReturn: true)

        waitForView(identifier: PropertyAutocompletePage.page)

        completion(application.cells.firstMatch)
    }

    func filterProperties(affordable: Bool? = nil, minimumBedrooms: Int? = nil) {
        if affordable == nil && minimumBedrooms == nil {
            return
        }

        waitForView(identifier: PropertySearchResultsPage.filter, hittable: true, in: application.navigationBars.buttons)
        tapBarButton(identifier: PropertySearchResultsPage.filter)

        waitForView(identifier: PropertyFilterPage.page)

        if let affordable = affordable {
            // TODO: Localize
            let value = affordable ? "Affordable Now" : "Any"
            selectPicker(value: value, in: PropertyFilterPage.affordability)
        }

        if let minimumBedrooms = minimumBedrooms {
            // TODO: Localize
            let values = ["Studio+", "1+", "2+", "3+", "4+", "5+", "6+", "7+", "8+", "9+", "10+"]
            let value = values[minimumBedrooms]
            selectPicker(value: value, in: PropertyFilterPage.minimumBedrooms)
        }

        tapBarButton(identifier: PropertyFilterPage.search)
    }

    func setupAffordability(outsideCapital: Decimal? = nil, outsideCapitalDescription: String? = nil, adjustedIncome: Decimal? = nil) {
        goTo(dashboardPage: .affordability)
        waitForView(identifier: AffordabilityPage.page)

        if let outsideCapital = outsideCapital {
            selectCell(identifier: AffordabilityPage.deposit)
            waitForView(identifier: DepositPage.page)
            tapButton(identifier: DepositPage.addOutsideCapital)
            waitForView(identifier: OutsideCapitalPage.page)
            type(String(describing: outsideCapital), in: OutsideCapitalPage.amount)
            type(outsideCapitalDescription ?? "", in: OutsideCapitalPage.description)
            tapButton(identifier: OutsideCapitalPage.apply)
            waitForView(identifier: DepositPage.page)
            goBack()
            waitForView(identifier: AffordabilityPage.page)
        }

        if let adjustedIncome = adjustedIncome {
            selectCell(identifier: AffordabilityPage.income)
            waitForView(identifier: IncomePage.page)
            tapButton(identifier: IncomePage.adjustYourIncome)
            type(String(describing: adjustedIncome), in: IncomePage.earnings)
            tapButton(identifier: IncomePage.saveChanges)
            waitForView(identifier: IncomePage.reset, hittable: true, in: application.buttons)
            goBack()
            waitForView(identifier: AffordabilityPage.page)
        }
    }

    private func linkAccounts(deselectThenSelect: Bool) {
        waitForView(identifier: AffordIQNavigator.LinkAcountsPage.page)

        if deselectThenSelect {
            accountIds.forEach { selectCell(identifier: $0) }
            accountIds.forEach { selectCell(identifier: $0) }
        }

        tapBarButton(identifier: AffordIQNavigator.LinkAcountsPage.save)
        waitForView(identifier: AffordIQNavigator.AccountsPage.page)
    }

    func onboardAccounts(deselectThenSelect: Bool = false) {
//    goTo(dashboardPage: .accounts)
        waitForView(identifier: AffordIQNavigator.AccountsOnboardingPage.page)
        tapButton(identifier: AffordIQNavigator.OverlayView.button)
        waitForView(identifier: AffordIQNavigator.SelectProviderPage.page)
        search("S")
        selectCell(identifier: "Santander")

        if !openBankingEphemeralSession {
            if let alert = waitForAlert(application: springboard),
               acceptSystemAlert(alert: alert, allow: true) {
                linkAccounts(deselectThenSelect: deselectThenSelect)
            }
        } else {
            linkAccounts(deselectThenSelect: deselectThenSelect)
        }
    }

    func renewAccountPermissions(accountId: String) {
        selectCell(identifier: accountId)
        waitForView(identifier: AffordIQNavigator.AccountDetailsPage.page)

        tapButton(identifier: AffordIQNavigator.AccountDetailsPage.renew)

        if !openBankingEphemeralSession {
            if let alert = waitForAlert(application: springboard),
               acceptSystemAlert(alert: alert, allow: true) {
                waitForView(identifier: AffordIQNavigator.AccountDetailsPage.page, hittable: true, timeout: 30.0)
            }
        } else {
            waitForView(identifier: AffordIQNavigator.AccountDetailsPage.page, hittable: true, timeout: 30.0)
        }
        goBack()
    }

    func renewAccountPermissions() {
        waitForView(identifier: AffordIQNavigator.AccountsPage.page)
        if let accountId = accountIds.last {
            renewAccountPermissions(accountId: accountId)
        }
    }

    func disconnectAccount(accountId: String) {
        selectCell(identifier: accountId)
        waitForView(identifier: AffordIQNavigator.AccountDetailsPage.page)

        tapButton(identifier: AffordIQNavigator.AccountDetailsPage.disconnect)

        if let alert = waitForSheetOrAlert() {
            _ = acceptSheetOrAlert(sheetOrAlert: alert)
        }

        waitForView(identifier: AffordIQNavigator.AccountsPage.page)
    }

    func disconnectAccount() {
        waitForView(identifier: AffordIQNavigator.AccountsPage.page)
        if let accountId = accountIds.randomElement() {
            disconnectAccount(accountId: accountId)
        }
    }

    func createUser() {
        waitForView(identifier: LoginPage.page)
        tapButton(identifier: LoginPage.createAccount)
        waitForView(identifier: RegistrationPage.page)
        type("Ken", in: RegistrationPage.givenName)
        type("Taylor", in: RegistrationPage.familyName)
        type("+447769747243", in: RegistrationPage.mobileNumber)
        type("16.05.1994", in: RegistrationPage.dateOfBirth)
        type("ken.taylor@tempuri.com", in: RegistrationPage.emailAddress)
        type("PA55word1234", in: RegistrationPage.password, isSecure: true)
        type("PA55word1234", in: RegistrationPage.confirmPassword, isSecure: true)
        tapButton(identifier: RegistrationPage.createAccount)
        waitForView(identifier: LoginPage.page)
    }

    func goTo(dashboardPage: DashboardPage) {
        waitForView(identifier: dashboardPage, hittable: true, in: application.tabBars.buttons)
        application.tabBars.buttons[dashboardPage.rawValue].tap()
    }
}
