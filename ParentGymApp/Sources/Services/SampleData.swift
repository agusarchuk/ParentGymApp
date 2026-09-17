//
//  SampleData.swift
//
//  Because this app has NO server/backend (per the "local database only"
//  requirement), there is no real gym system to pull children, packages
//  or attendance from. So the very first time the app is ever launched,
//  we create a couple of realistic example children so every screen has
//  something meaningful to show right away instead of being empty.
//
//  This seed data is calculated RELATIVE to "today" (not hard-coded to one
//  specific date), so the demo looks correct and up-to-date no matter when
//  you actually build and run the app.
//
//  NOTE: in a real gym system, attendance would normally be recorded by
//  staff scanning a child's QR code at the front desk, and packages would
//  be recorded when a parent pays. Since this is a local-only, parent-facing
//  app with no staff-side counterpart, we simulate that history here so the
//  Calendar and Payment Log screens have data to display.
//

import Foundation
import SwiftData

enum SampleData {

    /// Fills the local database with example data, but only if it is
    /// completely empty (so we never overwrite real data on later launches).
    static func seedIfNeeded(context: ModelContext) {
        let existingChildren = (try? context.fetch(FetchDescriptor<ChildProfile>())) ?? []
        guard existingChildren.isEmpty else { return }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Builds a package that covers the *calendar month* which is
        // `monthsAgo` months before the current one (0 = this month).
        func monthPackage(monthsAgo: Int, totalClasses: Int) -> Package {
            let monthDate = calendar.date(byAdding: .month, value: -monthsAgo, to: today) ?? today
            let interval = calendar.dateInterval(of: .month, for: monthDate)
                ?? DateInterval(start: monthDate, duration: 30 * 24 * 3600)
            let start = interval.start
            // `interval.end` is midnight of the 1st of the NEXT month, so
            // subtract a day to get the actual last day of this month.
            let end = calendar.date(byAdding: .day, value: -1, to: interval.end) ?? interval.end
            return Package(purchaseDate: start, startDate: start, endDate: end, totalClasses: totalClasses)
        }

        // Creates one attendance record for every day, from `start` up to
        // (but not including) today, that is a real scheduled class day for
        // `ageGroup`. If `skipOneForDemo` is true, the very first such day
        // is marked as NOT attended, so the Calendar screen has an example
        // of a "missed" day to display.
        func attendanceRecords(for ageGroup: AgeGroup, from start: Date, skipOneForDemo: Bool) -> [AttendanceRecord] {
            guard let dayBeforeToday = calendar.date(byAdding: .day, value: -1, to: today) else { return [] }

            var records: [AttendanceRecord] = []
            var cursor = start
            var alreadySkippedOne = false

            while cursor <= dayBeforeToday {
                let weekday = calendar.component(.weekday, from: cursor)
                if MasterSchedule.hasClass(for: ageGroup, weekday: weekday) {
                    if skipOneForDemo && !alreadySkippedOne {
                        records.append(AttendanceRecord(date: cursor, checkedIn: false))
                        alreadySkippedOne = true
                    } else {
                        records.append(AttendanceRecord(date: cursor, checkedIn: true))
                    }
                }
                guard let nextDay = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
                cursor = nextDay
            }
            return records
        }

        // MARK: Child 1 — Ana Smith (matches the provided design mockups)

        let ana = ChildProfile(name: "Ana Smith", ageGroup: .kids3to4)

        let anaActivePackage = monthPackage(monthsAgo: 0, totalClasses: 10)
        let anaLastMonthPackage = monthPackage(monthsAgo: 1, totalClasses: 8)
        let anaTwoMonthsAgoPackage = monthPackage(monthsAgo: 2, totalClasses: 8)
        anaActivePackage.child = ana
        anaLastMonthPackage.child = ana
        anaTwoMonthsAgoPackage.child = ana
        ana.packages = [anaActivePackage, anaLastMonthPackage, anaTwoMonthsAgoPackage]

        let anaAttendance = attendanceRecords(
            for: ana.ageGroup,
            from: anaActivePackage.startDate,
            skipOneForDemo: true
        )
        anaAttendance.forEach { $0.child = ana }
        ana.attendanceRecords = anaAttendance

        // MARK: Child 2 — Leo Smith (second kid, to demo the profile switcher)

        let leo = ChildProfile(name: "Leo Smith", ageGroup: .kids6to7)

        let leoActivePackage = monthPackage(monthsAgo: 0, totalClasses: 8)
        let leoLastMonthPackage = monthPackage(monthsAgo: 1, totalClasses: 8)
        leoActivePackage.child = leo
        leoLastMonthPackage.child = leo
        leo.packages = [leoActivePackage, leoLastMonthPackage]

        let leoAttendance = attendanceRecords(
            for: leo.ageGroup,
            from: leoActivePackage.startDate,
            skipOneForDemo: false
        )
        leoAttendance.forEach { $0.child = leo }
        leo.attendanceRecords = leoAttendance

        // Save everything to the local database.
        context.insert(ana)
        context.insert(leo)

        do {
            try context.save()
        } catch {
            print("⚠️ Could not save sample data: \(error)")
        }
    }
}
