//
//  AffordIQNavigator+Gestures.swift
//  AffordIQUITests
//
//  Created by Simon Lawrence on 08/01/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import XCTest

extension AffordIQNavigator {
    func swipe(identifier: String, direction: UISwipeGestureRecognizer.Direction, in query: XCUIElementQuery? = nil) {
        let query = query ?? application.otherElements
        waitForView(identifier: identifier, in: query)

        let element = query[identifier]

        var startVector = CGVector(dx: 0.5, dy: 0.5)
        var endVector = CGVector(dx: 0.5, dy: 0.5)

        switch direction {
        case .right:
            startVector.dx = 0.5
            endVector.dx = 3.0

        case .left:
            startVector.dx = 0.5
            endVector.dx = -2.5

        case .up:
            startVector.dy = 0.5
            endVector.dy = -2.5

        case .down:
            startVector.dy = 0.5
            endVector.dy = 3.0

        default:
            break
        }

        let startPoint = element.coordinate(withNormalizedOffset: startVector)
        let endPoint = element.coordinate(withNormalizedOffset: endVector)

        startPoint.press(forDuration: 0.01, thenDragTo: endPoint, withVelocity: XCUIGestureVelocity.fast, thenHoldForDuration: 0.01)
    }

    func swipe<T: RawRepresentable>(identifier: T, direction: UISwipeGestureRecognizer.Direction, in query: XCUIElementQuery? = nil) where T.RawValue == String {
        swipe(identifier: identifier.rawValue, direction: direction, in: query)
    }
}
