//
//  AffordIQNavigator+Picking.swift
//  AffordIQUITests
//
//  Created by Simon Lawrence on 08/01/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import XCTest

extension AffordIQNavigator {
    func selectCell(identifier: String) {
        waitForView(identifier: identifier, in: application.cells)
        let row = application.cells[identifier].firstMatch
        scrollTo(cell: row)
        row.tap()
    }

    func selectCell<T: RawRepresentable>(identifier: T) where T.RawValue == String {
        selectCell(identifier: identifier.rawValue)
    }
}

extension AffordIQNavigator {
    func selectPicker(value: String, index: Int = 0, activate: Bool = true, in identifier: String) {
        if activate {
            waitForView(identifier: identifier, in: application.textFields)
            application.textFields[identifier].tap()
            waitForView(identifier: identifier, in: application.pickers)
        }

        application.pickers[identifier].pickerWheels.element(boundBy: index).adjust(toPickerWheelValue: value)
    }

    func selectPicker<T: RawRepresentable>(value: String, index: Int = 0, activate: Bool = true, in identifier: T) where T.RawValue == String {
        selectPicker(value: value, index: index, activate: activate, in: identifier.rawValue)
    }

    func selectDatePicker(value: String, index: Int = 0, activate: Bool = true, in identifier: String) {
        if activate {
            waitForView(identifier: identifier, in: application.textFields)
            application.textFields[identifier].tap()
            waitForView(identifier: identifier, in: application.datePickers)
        }
        application.datePickers[identifier].pickerWheels.element(boundBy: index).adjust(toPickerWheelValue: value)
    }

    func selectDatePicker<T: RawRepresentable>(value: String, index: Int = 0, activate: Bool = true, in identifier: T) where T.RawValue == String {
        selectDatePicker(value: value, index: index, activate: activate, in: identifier.rawValue)
    }
}
