//
//  NumberFormatters.swift
//  AffordIQNetworkKit
//
//  Created by Sultangazy Bukharbay on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct NumberFormatters {
    private struct FormatDetails: Hashable {
        let locale: String
        let currencyCode: String?
        let rounded: Bool
    }
    
    private static let dispatchQueue = DispatchQueue(
        label: "com.blackarrow.numberFormatting",
        qos: .userInteractive,
        attributes: [],
        autoreleaseFrequency: .workItem,
        target: nil
    )
    
    private static var formatters: [FormatDetails: NumberFormatter] = [:]
    
    public static func numberFormatter(currencyCode: String?, rounded: Bool = false) -> NumberFormatter {
        let formatDetails = FormatDetails(locale: "en_GB", currencyCode: currencyCode, rounded: rounded)
        var result: NumberFormatter!
        
        dispatchQueue.sync {
            if let numberFormatter = formatters[formatDetails] {
                result = numberFormatter
            } else {
                let numberFormatter = NumberFormatter()
                if let currencyCode = currencyCode,
                   !currencyCode.isEmpty {
                    numberFormatter.currencyCode = currencyCode
                    numberFormatter.numberStyle = .currency
                } else {
                    numberFormatter.numberStyle = .decimal
                }
                numberFormatter.generatesDecimalNumbers = true
                if formatDetails.rounded {
                    numberFormatter.maximumFractionDigits = 0
                    numberFormatter.minimumFractionDigits = 0
                } else {
                    numberFormatter.maximumFractionDigits = 2
                }
                numberFormatter.locale = Locale(identifier: "en_GB")
                numberFormatter.generatesDecimalNumbers = true
                formatters[formatDetails] = numberFormatter
                
                result = numberFormatter
            }
        }
        
        return result
    }
    
    public static func format(
        amount: Decimal?,
        currencyCode: String?,
        rounded: Bool = false,
        absoluteValue: Bool = false
    ) -> String {
        guard let amount = amount else { return "-" }
        
        let numberFormatter = self.numberFormatter(currencyCode: currencyCode, rounded: rounded)
        let displayAmount = absoluteValue ? abs(amount) : amount
        return numberFormatter.string(from: displayAmount as NSDecimalNumber)!
    }
    
    public static func from(_ string: String?) -> Decimal? {
        guard let string = string else { return nil }
        
        let numberFormatter = self.numberFormatter(currencyCode: nil)
        return numberFormatter.number(from: string) as? Decimal
    }
}
