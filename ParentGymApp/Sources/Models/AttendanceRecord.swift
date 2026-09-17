//
//  AttendanceRecord.swift
//
//  Represents one calendar day where a child either attended their class
//  or was expected to but didn't. In a full system, staff at the gym would
//  create these records by scanning the child's QR code at check-in — this
//  app (the parent's app) only ever *reads* attendance, it never writes it
//  (see the README for more on this local-only demo setup).
//

import Foundation
import SwiftData

@Model
final class AttendanceRecord {

    @Attribute(.unique) var id: UUID

    /// The calendar day this record is for. We only care about the
    /// day/month/year part (time is ignored/zeroed out).
    var date: Date

    /// True if the child actually checked in / attended that day.
    var checkedIn: Bool

    /// The child this attendance record belongs to.
    var child: ChildProfile?

    init(date: Date, checkedIn: Bool) {
        self.id = UUID()
        self.date = date
        self.checkedIn = checkedIn
    }
}
