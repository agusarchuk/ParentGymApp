//
//  CalendarDayStatus.swift
//
//  This is the "brain" of the Calendar screen: for one specific day and
//  one specific child, it decides which of the highlighted states that
//  day should be shown in. Keeping this logic in its own file (separate
//  from the SwiftUI view code) makes it easy to read on its own and easy
//  to unit-test later if needed.
//
//  The rules implemented here are:
//   1. If the child is NOT scheduled for a class that day (it's not one of
//      their age group's class weekdays) -> `.notScheduled` (plain day).
//   2. If the child actually checked in that day -> `.attended`.
//   3. Otherwise, if the day has already passed -> `.missed`
//      (a scheduled class the child did not attend).
//   4. Otherwise (the day is today or in the future) -> `.paid` if an
//      active package covers that date, or `.unpaid` if it does not.
//

import Foundation

enum CalendarDayStatus: Equatable {
    case notScheduled   // Not a class day for this child's age group at all.
    case attended        // Child checked in that day.
    case missed          // Past class day, child did not check in.
    case paid             // Upcoming/today class day, covered by a paid package.
    case unpaid           // Upcoming/today class day, NOT covered by any package yet.

    /// Works out the status for one calendar day for one child.
    static func compute(for date: Date, child: ChildProfile) -> CalendarDayStatus {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let day = calendar.startOfDay(for: date)

        // Step 1: is this weekday even a class day for the child's age group?
        let weekday = calendar.component(.weekday, from: day)
        guard MasterSchedule.hasClass(for: child.ageGroup, weekday: weekday) else {
            return .notScheduled
        }

        // Step 2: did the child actually attend on this exact day?
        let attendanceRecord = child.attendanceRecords.first { calendar.isDate($0.date, inSameDayAs: day) }
        if attendanceRecord?.checkedIn == true {
            return .attended
        }

        // Step 3: if the day is in the past and wasn't attended, it was missed.
        if day < today {
            return .missed
        }

        // Step 4: today or future — paid if an active package's date range
        // covers this day, otherwise unpaid.
        let isCoveredByAPackage = child.packages.contains { package in
            day >= calendar.startOfDay(for: package.startDate) &&
            day <= calendar.startOfDay(for: package.endDate)
        }
        return isCoveredByAPackage ? .paid : .unpaid
    }
}
