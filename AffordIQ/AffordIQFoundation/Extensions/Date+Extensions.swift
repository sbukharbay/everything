//
//  Date+Extensions.swift
//  AffordIQFoundation
//
//  Created by Asilbek Djamaldinov on 23/12/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

public extension Date {
    func daysBetween(date: Date) -> Int {
        let calendar = Calendar.current
        let date1 = calendar.startOfDay(for: self)
        let date2 = calendar.startOfDay(for: date)
        if let daysBetween = calendar.dateComponents([.day], from: date1, to: date2).day {
            return daysBetween
        }
        return 0
    }
    
    /// Return string which describes date in human readable format.
    ///
    /// ```
    ///  Less 60 seconds ago -> "Now"
    ///  At the same calendaric day -> "Today"
    ///  One day before than calendaric day -> "Yesterday"
    ///  Any other date -> "DD/MM/YYYY"
    /// ```
    func descriptiveString(dateStyle: DateFormatter.Style = .short) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        
        let daysBetween = self.daysBetween(date: Date())
        
        if notificationDeliveredLessThanMinuteAgo() {
            return "Now"
        } else if daysBetween == 0 {
            return "Today"
        } else if daysBetween == 1 {
            return "Yesterday"
        }
        return formatter.string(from: self)
    }
    
    /// Is notification came less than a minute ago?
    private func notificationDeliveredLessThanMinuteAgo() -> Bool {
        let delivered = self.timeIntervalSince1970
        let now = Date().timeIntervalSince1970
        
        let difference = now - delivered
        
        return difference < 60
    }
    
    /// Function to compute the first day of the month for a given date using Calendar
    func firstDayOfMonth() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)!
    }
    
    /// Check is in the same year
    func isInSameYear(as date: Date) -> Bool { isEqual(to: date, toGranularity: .year) }
    
    func isEqual(to date: Date,
                 toGranularity component: Calendar.Component,
                 in calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, equalTo: date, toGranularity: component)
    }
}

public extension Date {
    var startOfMonth: Date {
        let monthYear = Calendar.autoupdatingCurrent.dateComponents([.year, .month], from: self)
        let result = Calendar.autoupdatingCurrent.date(from: monthYear)!

        return result
    }

    /// Display as "dd/MM/yyyy"
    func asStringDDMMYYYY() -> String {
        let dateFormatter = DateFormatter.ddMMYYYY
        dateFormatter.timeZone = .current
        let string = dateFormatter.string(from: self)
        return string
    }

    /// Display as "yyyy-MM-dd"
    func asStringYYYYMMDD() -> String {
        let dateFormatter = DateFormatter.YYYYMMdd
        dateFormatter.timeZone = .current
        let string = dateFormatter.string(from: self)
        return string
    }

    /// Display as "yyyy-MM-dd'T'HH:mm:ssXXX"
    func asStringFullDate() -> String {
        let dateFormatter = DateFormatter.fullDate
        dateFormatter.timeZone = .current
        dateFormatter.locale = Locale(identifier: "en_UK")
        let string = dateFormatter.string(from: self)
        return string
    }
    
    /// Display as "dd(st, nd, th) MMMM"
    func asStringFullMonth() -> String {
        // Use this to add st, nd, th, to the day
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .ordinal
        numberFormatter.locale = Locale.current

        // Set other sections as preferred
        let monthFormatter = DateFormatter()
        monthFormatter.timeZone = .current
        monthFormatter.dateFormat = "MMMM"

        // Works well for adding suffix
        let dayFormatter = DateFormatter()
        dayFormatter.timeZone = .current
        dayFormatter.dateFormat = "dd"

        let dayString = dayFormatter.string(from: self)
        let monthString = monthFormatter.string(from: self)

        // Add the suffix to the day
        let dayNumber = NSNumber(value: Int(dayString)!)
        let day = numberFormatter.string(from: dayNumber)!
        
        return "\(day) \(monthString)"
    }
}

public extension DateFormatter {
    /// Date format "dd/MM/yyyy"
    static let ddMMYYYY: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter
    }()

    /// Date format "yyyy-MM-dd"
    static let YYYYMMdd: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()

    /// Date format "yyyy-MM-dd'T'HH:mm:ssXXX"
    static let fullDate: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXX"
        return dateFormatter
    }()
}
