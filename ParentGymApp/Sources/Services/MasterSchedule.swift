//
//  MasterSchedule.swift
//
//  This file encodes the GYM'S weekly class schedule (which age group has
//  a class on which weekday, and at what time). This is the same
//  information printed on the gym's "Class Schedule 2026-2027" flyer.
//
//  It is NOT something that changes per-child — every child simply belongs
//  to one age group, and this table tells the app which calendar days are
//  "class days" for that age group. That is what lets the Calendar screen
//  highlight "days of the chosen age group" as the requirements describe.
//
//  Because this app stores everything locally (no server), this schedule
//  is just hard-coded Swift data. If the gym changes its schedule, this is
//  the one file that needs to be edited.
//

import Foundation

/// The age groups the gym offers, taken from the class schedule flyer.
/// `String` raw values are used so we can store them easily on the
/// SwiftData `ChildProfile` model and show a friendly label in the UI.
enum AgeGroup: String, CaseIterable, Codable, Identifiable {
    case kids3to4
    case kids4to5
    case kids6to7
    case juniors8plus

    var id: String { rawValue }

    /// The short label shown in badges, e.g. the "3-4 yo" pill on screen 2.
    var shortLabel: String {
        switch self {
        case .kids3to4:      return "3-4 yo"
        case .kids4to5:      return "4-5 yo"
        case .kids6to7:      return "6-7 yo"
        case .juniors8plus:  return "8+ yo"
        }
    }

    /// A longer, friendlier name for menus (profile switcher, etc).
    var displayName: String {
        switch self {
        case .kids3to4:      return "Kids 3-4 y.o"
        case .kids4to5:      return "Kids 4-5 y.o"
        case .kids6to7:      return "Kids 6-7 y.o"
        case .juniors8plus:  return "Juniors 8+ y.o"
        }
    }
}

/// One row of the weekly schedule flyer: "On this weekday, this age group
/// has a class from this time to that time."
///
/// `weekday` uses the same numbering as `Calendar` / `DateComponents`:
/// 1 = Sunday, 2 = Monday, 3 = Tuesday, ... 7 = Saturday.
struct ClassSession {
    let weekday: Int
    let ageGroup: AgeGroup
    let startHour: Int
    let startMinute: Int

    /// A "15:30" style formatted start time, used on the Profile screen.
    /// Built directly from the hour/minute numbers (rather than via `Date`)
    /// so we don't need a full, valid calendar date just to show a time.
    var startTimeText: String {
        String(format: "%02d:%02d", startHour, startMinute)
    }
}

/// The full weekly schedule, transcribed from the gym's flyer image.
/// (Sunday has no classes, so there are no entries for weekday == 1.)
enum MasterSchedule {

    static let allSessions: [ClassSession] = [
        // Monday
        ClassSession(weekday: 2, ageGroup: .kids4to5,     startHour: 15, startMinute: 30),
        ClassSession(weekday: 2, ageGroup: .kids6to7,     startHour: 16, startMinute: 40),
        ClassSession(weekday: 2, ageGroup: .juniors8plus, startHour: 17, startMinute: 50),

        // Tuesday
        ClassSession(weekday: 3, ageGroup: .kids6to7,     startHour: 15, startMinute: 30),
        ClassSession(weekday: 3, ageGroup: .juniors8plus, startHour: 16, startMinute: 40),
        ClassSession(weekday: 3, ageGroup: .kids3to4,     startHour: 17, startMinute: 50),

        // Wednesday
        ClassSession(weekday: 4, ageGroup: .kids4to5,     startHour: 15, startMinute: 30),
        ClassSession(weekday: 4, ageGroup: .kids6to7,     startHour: 16, startMinute: 40),
        ClassSession(weekday: 4, ageGroup: .juniors8plus, startHour: 17, startMinute: 50),

        // Thursday
        ClassSession(weekday: 5, ageGroup: .kids6to7,     startHour: 15, startMinute: 30),
        ClassSession(weekday: 5, ageGroup: .kids3to4,     startHour: 16, startMinute: 40),
        ClassSession(weekday: 5, ageGroup: .juniors8plus, startHour: 17, startMinute: 50),

        // Friday
        ClassSession(weekday: 6, ageGroup: .kids4to5,     startHour: 15, startMinute: 30),
        ClassSession(weekday: 6, ageGroup: .kids6to7,     startHour: 16, startMinute: 40),
        ClassSession(weekday: 6, ageGroup: .juniors8plus, startHour: 17, startMinute: 50),

        // Saturday
        ClassSession(weekday: 7, ageGroup: .kids3to4,     startHour: 10, startMinute: 0),
        ClassSession(weekday: 7, ageGroup: .kids4to5,     startHour: 11, startMinute: 10),
        ClassSession(weekday: 7, ageGroup: .kids6to7,     startHour: 12, startMinute: 20),
    ]

    /// Returns the class session (if any) for a given age group on a given weekday.
    static func session(for ageGroup: AgeGroup, weekday: Int) -> ClassSession? {
        allSessions.first { $0.ageGroup == ageGroup && $0.weekday == weekday }
    }

    /// True if the given age group has a class at all on this weekday.
    static func hasClass(for ageGroup: AgeGroup, weekday: Int) -> Bool {
        session(for: ageGroup, weekday: weekday) != nil
    }
}
