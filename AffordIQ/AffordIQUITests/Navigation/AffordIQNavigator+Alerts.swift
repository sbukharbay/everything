//
//  AffordIQNavigator+Alerts.swift
//  AffordIQUITests
//
//  Created by Simon Lawrence on 08/01/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import XCTest

extension AffordIQNavigator {
    func waitForAlert(application: XCUIApplication? = nil, timeout: TimeInterval = AffordIQNavigator.defaultTimeout) -> XCUIElement? {
        guard let application = application ?? self.application else {
            return nil
        }
        let alert = application.alerts.firstMatch
        if alert.waitForExistence(timeout: timeout) {
            return alert
        }
        return nil
    }

    func waitForSheetOrAlert(timeout: TimeInterval = AffordIQNavigator.defaultTimeout) -> XCUIElement? {
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        let sheetOrAlert = isIPad ? application.alerts.firstMatch : application.sheets.firstMatch
        if sheetOrAlert.waitForExistence(timeout: timeout) {
            return sheetOrAlert
        }
        return nil
    }

    func acceptSheetOrAlert(sheetOrAlert: XCUIElement, cancel: Bool = false, index: Int? = nil) -> Bool {
        guard sheetOrAlert.elementType == .sheet || sheetOrAlert.elementType == .alert else {
            return false
        }

        let isSheet = sheetOrAlert.elementType == .sheet
        var defaultIndex = cancel ? sheetOrAlert.buttons.count - 1 : 0

        if !isSheet {
            defaultIndex = cancel ? 0 : sheetOrAlert.buttons.count - 1
        }
        let buttonIndex = index ?? defaultIndex

        let indexButton = sheetOrAlert.buttons.element(boundBy: buttonIndex)

        if indexButton.exists && indexButton.isHittable {
            indexButton.tap()
            return true
        }

        return false
    }

    func acceptSystemAlert(alert: XCUIElement, allow: Bool = true) -> Bool {
        guard alert.elementType == .alert else {
            return false
        }

        let buttonIndex = allow ? alert.buttons.count - 1 : 0
        let indexButton = alert.buttons.element(boundBy: buttonIndex)

        if indexButton.exists && indexButton.isHittable {
            indexButton.tap()
            return true
        }

        return false
    }
}
