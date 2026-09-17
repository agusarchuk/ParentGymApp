//
//  Package.swift
//
//  Represents one purchased "class pass" for a child, e.g. "8 classes,
//  bought on 12 Sep, valid until 10 Oct". This matches the 3 columns shown
//  on the Payment Log screenshot: Payment date / Package (classes) / End date.
//
//  A package is "active" while today's date falls between its start and
//  end date — see `ChildProfile.activePackage`. Any class day that falls
//  within an active package's date range counts as "paid" on the Calendar
//  screen.
//

import Foundation
import SwiftData

@Model
final class Package {

    @Attribute(.unique) var id: UUID

    /// The date the parent paid for this package (shown as "Payment date").
    var purchaseDate: Date

    /// The first day this package's classes are valid from.
    var startDate: Date

    /// The last day this package's classes are valid until (inclusive).
    var endDate: Date

    /// How many classes this package includes, e.g. 8.
    var totalClasses: Int

    /// The child this package belongs to.
    var child: ChildProfile?

    init(purchaseDate: Date, startDate: Date, endDate: Date, totalClasses: Int) {
        self.id = UUID()
        self.purchaseDate = purchaseDate
        self.startDate = startDate
        self.endDate = endDate
        self.totalClasses = totalClasses
    }
}
