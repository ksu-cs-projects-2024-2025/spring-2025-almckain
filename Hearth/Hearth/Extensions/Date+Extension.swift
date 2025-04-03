//
//  Date+Extension.swift
//  Hearth
//
//  Created by Aaron McKain on 2/17/25.
//

import Foundation

extension Date {
    static var capitalizedFirstLettersOfWeekdays: [String] {
        let calendar = Calendar.current
        let weekdays = calendar.shortWeekdaySymbols

        return weekdays.map { weekday in
            guard let firstLetter = weekday.first else { return "" }
            return String(firstLetter).capitalized
        }
    }
    
    static var fullMonthNames: [String] {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current

        return (1...12).compactMap { month in
            dateFormatter.setLocalizedDateFormatFromTemplate("MMMM")
            let date = Calendar.current.date(from: DateComponents(year: 2000, month: month, day: 1))
            return date.map { dateFormatter.string(from: $0) }
        }
    }
    
    var startOfMonth: Date {
        Calendar.current.dateInterval(of: .month, for: self)!.start
    }
    
    var endOfMonth: Date {
        let lastDay = Calendar.current.dateInterval(of: .month, for: self)!.end
        return Calendar.current.date(byAdding: .day, value: -1, to: lastDay)!
    }
    
    var startOfPreviousMonth: Date {
        let dayInPreviousMonth = Calendar.current.date(byAdding: .month, value: -1, to: self)!
        return dayInPreviousMonth.startOfMonth
    }
    
    var numbersOfDaysInMonth: Int {
        Calendar.current.component(.day, from: endOfMonth)
    }
    
    var sundayBeforeStart: Date {
        let startOfMonthWeekday = Calendar.current.component(.weekday, from: startOfMonth)
        let numberFromPreviousMonth = startOfMonthWeekday - 1
        return Calendar.current.date(byAdding: .day, value: -numberFromPreviousMonth, to: startOfMonth)!
    }
    
    var calendarDisplayDays: [Date] {
        var days: [Date] = []
        for dayOffset in 0..<numbersOfDaysInMonth {
            let newDay = Calendar.current.date(byAdding: .day, value: dayOffset, to: startOfMonth)
            days.append(newDay!)
        }
        
        for dayOffset in 0..<startOfPreviousMonth.numbersOfDaysInMonth {
            let newDay = Calendar.current.date(byAdding: .day, value: dayOffset, to: startOfPreviousMonth)
            days.append(newDay!)
        }
        return days.filter { $0 >= sundayBeforeStart && $0 <= endOfMonth }.sorted(by: <)
    }
    
    var monthInt: Int {
        Calendar.current.component(.month, from: self)
    }
    
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    var isSunday: Bool {
        let weekday = Calendar.current.component(.weekday, from: self)
        return weekday == 1
    }
    
    var isAfter9AM: Bool {
        let hour = Calendar.current.component(.hour, from: self)
        return hour >= 9
    }
    
    var isMonday: Bool {
        let weekday = Calendar.current.component(.weekday, from: self)
        return weekday == 2
    }
    
    /// Returns the Sunday of the current week at 00:00 in the local time zone.
    var startOfCurrentWeek: Date {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: self)
        // In Swift's default calendar, Sunday = 1, Monday = 2, etc.
        let daysSinceSunday = weekday - 1  // 0 if today is Sunday, 1 if Monday, etc.
        // Subtract that many days from "today at midnight":
        let startOfToday = calendar.startOfDay(for: self)
        return calendar.date(byAdding: .day, value: -daysSinceSunday, to: startOfToday)!
    }

    /// Returns an array of 7 dates starting from the Sunday of the current week.
    var daysOfCurrentWeek: [Date] {
        let start = self.startOfCurrentWeek
        return (0..<7).compactMap {
            Calendar.current.date(byAdding: .day, value: $0, to: start)
        }
    }

    /// Check if this Date is the same calendar day as 'other'
    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }
    
    var endOfDay: Date {
        var comps = DateComponents()
        comps.day = 1
        comps.second = -1
        return Calendar.current.date(byAdding: comps, to: self.startOfDay) ?? self
    }
}
