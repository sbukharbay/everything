//
//  Rounding.swift
//  AffordIQFoundation
//
//  Created by Sultangazy Bukharbay on 27/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public protocol Rounding {
    func rounded(places: Int16, roundingMode: NSDecimalNumber.RoundingMode) -> Self
}

extension MonetaryAmount: Rounding {
    public func rounded(places: Int16 = 2, roundingMode: NSDecimalNumber.RoundingMode = .plain) -> MonetaryAmount {
        guard let amount = amount else {
            return MonetaryAmount(amount: nil, currencyCode: currencyCode)
        }
        
        return MonetaryAmount(amount: amount.rounded(places: places, roundingMode: roundingMode), currencyCode: currencyCode)
    }
}

extension Decimal: Rounding {
    public var rounded: Int {
        return (self.rounded() as NSDecimalNumber).intValue
    }
    
    public var roundedUp: Int {
        return (rounded(roundingMode: .up) as NSDecimalNumber).intValue
    }
    
    public func rounded(places: Int16 = 0, roundingMode: NSDecimalNumber.RoundingMode = .plain) -> Decimal {
        let behavior = NSDecimalNumberHandler(roundingMode: roundingMode, scale: places, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        
        return (self as NSDecimalNumber).rounding(accordingToBehavior: behavior) as Decimal
    }
}
