//
//  AffordIQDates.swift
//  AffordIQFoundation
//
//  Created by Sultangazy Bukharbay on 02/11/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public var systemDate: Date {
    #if DEBUG
    if let value = ProcessInfo.processInfo.environment["MOCKING"], value == "true" {
        // 2021/01/20 11:27:04
        return Date(timeIntervalSinceReferenceDate: 632_834_824.0)
    } else {
        return Date()
    }
    #else
    return Date()
    #endif
}

public let iso8601WithFractionalSecondsFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXX"

    return formatter
}()

public let iso8601Formatter = ISO8601DateFormatter()

public extension JSONDecoder.DateDecodingStrategy {
    static let iso8601WithFractionalSeconds = custom {
        let container = try $0.singleValueContainer()
        let string = try container.decode(String.self)

        let stringValue = string.hasSuffix("Z") ? string : string + "Z"
        let date = iso8601WithFractionalSecondsFormatter.date(from: stringValue)

        if let date = date {
            return date
        } else {
            if let date = iso8601Formatter.date(from: string) {
                return date
            }
        }

        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(string)")
    }
}
