//
//  Decimal+Extensions.swift
//  AffordIQFoundation
//
//  Created by Asilbek Djamaldinov on 27/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public extension Decimal {
    var doubleValue: Double {
        return (self as NSDecimalNumber).doubleValue
    }
    
    var floatValue: Float {
        return Float(doubleValue)
    }
    
    var cgFloatValue: CGFloat {
        return CGFloat(doubleValue)
    }
}
