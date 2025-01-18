//
//  String+Formatting.swift
//  AffordIQFoundation
//
//  Created by Sultangazy Bukharbay on 02/11/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

public extension String {
    static var paragraphBreak: String {
        return "\u{2029}"
    }
    
    var capitalizedFirstLetter: String {
        let first = String(self.prefix(1)).capitalized
        let other = String(self.dropFirst())
        return first + other
    }
}

public extension NSAttributedString {
    var trailingAttributes: [NSAttributedString.Key: Any] {
        if string.isEmpty {
            return [:]
        }
        return attributes(at: string.count - 1, effectiveRange: nil)
    }
}

public extension NSMutableAttributedString {
    func append(_ string: String?, attributes: [NSAttributedString.Key: Any]) {
        guard let string = string else { return }

        let attributedString = NSAttributedString(string: string, attributes: attributes)
        append(attributedString)
    }

    func set(attributes: [NSAttributedString.Key: Any], firstRangeOf substring: String?) {
        guard let substring = substring else { return }

        if let range = string.range(of: substring, options: [.caseInsensitive, .diacriticInsensitive]) {
            let nsRange = NSRange(range, in: string)

            if nsRange.location != NSNotFound {
                setAttributes(attributes, range: nsRange)
            }
        }
    }

    func set(attributes: [NSAttributedString.Key: Any], allRangesOf substring: String?) {
        guard let substring = substring else { return }

        var searchRange = NSRange(location: 0, length: string.count)

        while let range = string.range(of: substring, options: [.caseInsensitive, .diacriticInsensitive], range: Range(searchRange, in: string), locale: nil) {
            let matchRange = NSRange(range, in: string)
            if matchRange.location != NSNotFound {
                setAttributes(attributes, range: matchRange)
            }

            searchRange = NSRange(location: matchRange.location + matchRange.length, length: searchRange.length - matchRange.length)

            if searchRange.length <= 0 {
                break
            }
        }
    }
}

public extension String {
    var sanitized: String? {
        let value = trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        if value.isEmpty {
            return nil
        }

        return value
    }

    func replacing(range: NSRange, with string: String) -> String {
        if let replacementRange = Range(range, in: self) {
            return replacingCharacters(in: replacementRange, with: string)
        }

        return self
    }

    func currencyInputFormatting() -> String {
        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        formatter.locale = Locale(identifier: "en_GB")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        number = NSNumber(value: formatAndConvert())

        return formatter.string(from: number)!
    }

    func formatAndConvert() -> Double {
        // remove from String: "$", ".", ","
        guard let regex = try? NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive) else { return 0 }
        let amountWithPrefix = regex.stringByReplacingMatches(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, count), withTemplate: "")

        let double = (amountWithPrefix as NSString).doubleValue
        return double / 100
    }
}

public extension String {
    static func random(length: Int, from characters: String) -> String {
        String((0 ..< length).map { _ in characters.randomElement()! })
    }

    static func randomAlpha(length: Int) -> String {
        random(length: length, from: "ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    }

    static func randomNumeric(length: Int) -> String {
        random(length: length, from: "0123456789")
    }

    static var missingValuePlaceholder: String {
        NSLocalizedString("-", bundle: Bundle.main,
                          comment: "Placeholder for missing values")
    }
}

public extension String {
    /// Change date format from DDMMYYYY to YYYYMMDD
    func changeDOBDateFormat() -> String {
        guard let myDate = DateFormatter.ddMMYYYY.date(from: self) else { return self }
        
        return DateFormatter.YYYYMMdd.string(from: myDate)
    }
    
    /// Converts string into Date in format DDMMYYYY taking into consideration time zone
    func asDate() -> Date {
        let dateFormatter = DateFormatter.ddMMYYYY
        dateFormatter.timeZone = .current
        let date = dateFormatter.date(from: self)
        return date ?? Date()
    }
    
    /// Converts string into Date in ISO format ("2022-11-28T00:00:00Z")
    func asISODate() -> Date {
        let dateFormatter = ISO8601DateFormatter()
        let date = dateFormatter.date(from: self)
        
        return date ?? Date()
    }
}
