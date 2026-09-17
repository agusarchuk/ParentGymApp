//
//  ChildProfile.swift
//
//  Represents ONE kid attending the gym. A parent account in this app can
//  have several ChildProfiles (that's what the profile switcher on the
//  first screen is for).
//
//  This is a SwiftData "@Model" class, which means SwiftData automatically
//  saves/loads it from the local on-device database for us — we never have
//  to write any manual save/load code.
//

import Foundation
import SwiftData

@Model
final class ChildProfile {

    /// A unique identifier for this child. `@Attribute(.unique)` tells
    /// SwiftData to enforce that no two ChildProfiles ever share an id.
    @Attribute(.unique) var id: UUID

    /// The child's full name, e.g. "Ana Smith".
    var name: String

    /// Which weekly class group this child belongs to. Stored as the
    /// enum's raw String value because SwiftData stores simple types most
    /// reliably; `ageGroup` below converts it back to the `AgeGroup` enum.
    var ageGroupRawValue: String

    /// The text encoded into this child's QR code. Staff at the gym would
    /// scan this to check the child in. It just needs to be unique and
    /// stable, so we use the child's id.
    var qrCodeValue: String

    /// Every package (payment) ever bought for this child.
    /// `.cascade` means if a child is deleted, their packages are deleted too.
    @Relationship(deleteRule: .cascade, inverse: \Package.child)
    var packages: [Package] = []

    /// Every attendance record (checked-in class day) for this child.
    @Relationship(deleteRule: .cascade, inverse: \AttendanceRecord.child)
    var attendanceRecords: [AttendanceRecord] = []

    init(name: String, ageGroup: AgeGroup) {
        // SwiftData's @Model requires every stored property to be assigned
        // before `self` can be READ from inside the initializer — so we
        // build the id in a local constant first, rather than assigning it
        // to self.id and then reading self.id back on the next line.
        let newID = UUID()
        self.id = newID
        self.name = name
        self.ageGroupRawValue = ageGroup.rawValue
        self.qrCodeValue = "gymtracker://checkin/\(newID.uuidString)"
    }

    /// Convenience computed property so the rest of the app can work with
    /// the friendly `AgeGroup` enum instead of a raw string.
    var ageGroup: AgeGroup {
        get { AgeGroup(rawValue: ageGroupRawValue) ?? .kids3to4 }
        set { ageGroupRawValue = newValue.rawValue }
    }

    /// The package that covers "today" (its start...end date range contains
    /// today), if one exists. This is what the app treats as the
    /// "active package" shown on the Profile and Payment Log screens.
    var activePackage: Package? {
        let today = Date()
        return packages.first { $0.startDate <= today && today <= $0.endDate }
    }

    /// All packages that are NOT the active one, newest first. Shown as
    /// "History packages" on the Payment Log screen.
    var historyPackages: [Package] {
        packages
            .filter { $0.id != activePackage?.id }
            .sorted { $0.startDate > $1.startDate }
    }

    /// How many classes are left to use in the active package this month.
    /// Formula: total classes included in the package, minus how many of
    /// those class-days the child has already checked into.
    var classesRemainingInActivePackage: Int {
        guard let package = activePackage else { return 0 }
        let attendedCount = attendanceRecords.filter { record in
            record.checkedIn &&
            record.date >= package.startDate &&
            record.date <= package.endDate
        }.count
        return max(0, package.totalClasses - attendedCount)
    }
}
