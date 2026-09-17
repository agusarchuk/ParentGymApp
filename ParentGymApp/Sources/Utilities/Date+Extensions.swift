//
//  Date+Extensions.swift
//
//  Small helper functions for working with calendar days/months.
//  Keeping these here (instead of scattered inline in the views) makes
//  the Calendar screen's code much easier to read.
//

import Foundation

extension Date {

    /// Returns a new Date with the time set to midnight (start of day),
    /// so two dates can be compared by "which day" while ignoring the
    /// hour/minute/second.
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// True if `self` and `other` are the same calendar day.
    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }
}

extension Calendar {

    /// Builds the full grid of days to display for a "month view" calendar,
    /// including the leading days from the previous month needed to fill
    /// the first week (so the grid always starts on a Monday).
    ///
    /// Returns an array where each entry is a Date, or `nil` for the empty
    /// filler cells before the 1st of the month.
    func monthGridDays(containing date: Date) -> [Date?] {
        guard
            let monthInterval = self.dateInterval(of: .month, for: date),
            let firstOfMonth = self.date(from: self.dateComponents([.year, .month], from: monthInterval.start))
        else {
            return []
        }

        // How many days are in this month (28-31).
        let dayCount = self.range(of: .day, in: .month, for: firstOfMonth)?.count ?? 30

        // `weekday` is 1 = Sunday ... 7 = Saturday. We want our grid to
        // start on Monday, so we convert to a "days after Monday" offset.
        let firstWeekday = self.component(.weekday, from: firstOfMonth)
        let mondayBasedOffset = (firstWeekday + 5) % 7 // Mon=0, Tue=1, ... Sun=6

        var days: [Date?] = Array(repeating: nil, count: mondayBasedOffset)

        for dayNumber in 1...dayCount {
            if let day = self.date(byAdding: .day, value: dayNumber - 1, to: firstOfMonth) {
                days.append(day)
            }
        }

        return days
    }

    /// A friendly "September 2026" style label for a month.
    func monthTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }
}
