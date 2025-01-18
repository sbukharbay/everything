//
//  MonetaryAmount.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 23/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct MonetaryAmount: Codable, Hashable {
    public static var zero = MonetaryAmount(amount: Decimal.zero)
    public var currencyCode: String?
    public let amount: Decimal?
    
    enum CodingKeys: String, CodingKey {
        case currencyCode = "currency_code"
        case amount
    }
    
    /// Returns a short description of the currency amount without the decimal part in the current locale e.g. £1,000
    public var shortDescription: String {
        return NumberFormatters.format(amount: amount, currencyCode: currencyCode, rounded: true)
    }
    
    /// Returns a long description of the currency amount with the decimal part in the current locale e.g. £1,000,00
    public var longDescription: String {
        return NumberFormatters.format(amount: amount, currencyCode: currencyCode, rounded: false)
    }
    
    /// Returns a long description of the absolute value of currency amount with the decimal part in the current locale e.g. £1,000,00
    public var longDescriptionAbsolute: String {
        return NumberFormatters.format(amount: amount, currencyCode: currencyCode, rounded: false, absoluteValue: true)
    }
    
    /// Returns a short description of the currency amount without the decimal part or sign in the current locale e.g. £1,000
    public var shortDescriptionNoSign: String {
        return NumberFormatters.format(amount: amount, currencyCode: currencyCode, rounded: true, absoluteValue: true)
    }
    
    public var editingDescription: String {
        let result = NumberFormatters.format(amount: amount, currencyCode: nil, rounded: false)
        
        if let groupingSeparator = Locale.autoupdatingCurrent.groupingSeparator {
            return result.replacingOccurrences(of: groupingSeparator, with: "")
        }
        
        return result
    }
    
    public var descriptionNoGrouping: String {
        let result = description
        
        if let groupingSeparator = Locale.autoupdatingCurrent.groupingSeparator {
            return result.replacingOccurrences(of: groupingSeparator, with: "")
        }
        
        return result
    }
    
    // TODO: This probably needs to take the current locale into accout
    public init(amount: Decimal?, currencyCode: String? = "GBP") {
        self.currencyCode = currencyCode
        self.amount = amount
    }
    
    public static func + (left: MonetaryAmount, right: MonetaryAmount) -> MonetaryAmount {
        precondition(left.currencyCode == right.currencyCode)
        
        return MonetaryAmount(amount: (right.amount ?? Decimal.zero) + (left.amount ?? Decimal.zero),
                              currencyCode: left.currencyCode)
    }
    
    public static func - (left: MonetaryAmount, right: MonetaryAmount) -> MonetaryAmount {
        precondition(left.currencyCode == right.currencyCode)
        
        return MonetaryAmount(amount: (left.amount ?? Decimal.zero) - (right.amount ?? Decimal.zero),
                              currencyCode: left.currencyCode)
    }
    
    public static func + (left: MonetaryAmount, right: Decimal) -> MonetaryAmount {
        return MonetaryAmount(amount: right + (left.amount ?? Decimal.zero),
                              currencyCode: left.currencyCode)
    }
    
    public static func + (left: Decimal, right: MonetaryAmount) -> MonetaryAmount {
        return right + left
    }
    
    public static func - (left: MonetaryAmount, right: Decimal) -> MonetaryAmount {
        return MonetaryAmount(amount: (left.amount ?? Decimal.zero) - right,
                              currencyCode: left.currencyCode)
    }
    
    public static func - (left: Decimal, right: MonetaryAmount) -> MonetaryAmount {
        return MonetaryAmount(amount: left - (right.amount ?? Decimal.zero),
                              currencyCode: right.currencyCode)
    }
    
    public static func * (left: MonetaryAmount, right: MonetaryAmount) -> MonetaryAmount {
        precondition(left.currencyCode == right.currencyCode)
        
        return MonetaryAmount(amount: (left.amount ?? Decimal.zero) * (right.amount ?? Decimal.zero),
                              currencyCode: left.currencyCode)
    }
    
    public static func * (left: MonetaryAmount, right: Decimal) -> MonetaryAmount {
        return MonetaryAmount(amount: (left.amount ?? Decimal.zero) * right,
                              currencyCode: left.currencyCode)
    }
    
    public static func * (left: Decimal, right: MonetaryAmount) -> MonetaryAmount {
        return right * left
    }
    
    public static func / (left: MonetaryAmount, right: MonetaryAmount) -> MonetaryAmount {
        precondition(left.currencyCode == right.currencyCode)
        
        return MonetaryAmount(amount: (left.amount ?? Decimal.zero) / (right.amount ?? Decimal.zero),
                              currencyCode: left.currencyCode)
    }
    
    public static func / (left: MonetaryAmount, right: Decimal) -> MonetaryAmount {
        return MonetaryAmount(amount: (left.amount ?? Decimal.zero) / right,
                              currencyCode: left.currencyCode)
    }
    
    public static func / (left: Decimal, right: MonetaryAmount) -> MonetaryAmount {
        return MonetaryAmount(amount: left / (right.amount ?? Decimal.zero),
                              currencyCode: right.currencyCode)
    }
    
    public static func += (lhs: inout MonetaryAmount, rhs: MonetaryAmount) {
        lhs = lhs + rhs
    }
}

extension MonetaryAmount: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.amount ?? 0.00 < rhs.amount ?? 0.00
    }
}

extension MonetaryAmount: CustomStringConvertible, CustomDebugStringConvertible {
    /// Returns a description of the currency amount including the decimal part in the current locale e.g. £1,000.01
    public var description: String {
        return NumberFormatters.format(amount: amount, currencyCode: currencyCode, rounded: false)
    }
    
    public var debugDescription: String {
        return description
    }
}

public struct StringMonetaryAmount: Codable, Hashable {
    public let currencyCode: String
    public let amount: String?
    
    public init(amount: String?, currencyCode: String = "GBP") {
        self.currencyCode = currencyCode
        self.amount = amount
    }
    
    enum CodingKeys: String, CodingKey {
        case currencyCode = "currency_code"
        case amount
    }
}
