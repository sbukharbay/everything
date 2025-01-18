//
//  AffordIQNavigator+Scrolling.swift
//  AffordIQUITests
//
//  Created by Simon Lawrence on 08/01/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import XCTest

extension XCUIElement {
    var isVisible: Bool {
        if !exists || !isHittable || frame.isEmpty {
            return false
        }

        return XCUIApplication().windows.element(boundBy: 0).frame.contains(frame)
    }
}

extension AffordIQNavigator {
    func scrollTo(cell: XCUIElement) {
        while !cell.isVisible {
            let table = application.tables.element(boundBy: application.tables.count - 1)
            let startCoord = table.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            let endCoord = startCoord.withOffset(CGVector(dx: 0.0, dy: -150))
            startCoord.press(forDuration: 0.01, thenDragTo: endCoord)
        }
    }

    func scrollTo(element: XCUIElement) {
        while !element.isVisible {
            let scrollView = application.scrollViews.element(boundBy: application.scrollViews.count - 1)
            let startCoord = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            let endCoord = startCoord.withOffset(CGVector(dx: 0.0, dy: -20))
            startCoord.press(forDuration: 0.01, thenDragTo: endCoord)
        }
    }

    func scrollTo(identifier: String, in query: XCUIElementQuery? = nil) {
        let query = query ?? application.textFields
        let element = waitForView(identifier: identifier, in: query)
        scrollTo(element: element)
    }

    func scrollTo<T: RawRepresentable>(identifier: T, in query: XCUIElementQuery? = nil) where T.RawValue == String {
        scrollTo(identifier: identifier.rawValue, in: query)
    }
}
