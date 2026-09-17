//
//  Theme.swift
//
//  All the colors, fonts and sizes used across the app live in ONE place.
//  This keeps every screen visually consistent, and means that if the
//  gym ever changes its brand colors we only need to edit this one file.
//
//  Colors were picked to match the "Funtastic Gymnastic" logo (pink/magenta)
//  provided in the design screenshots.
//

import SwiftUI

enum Theme {

    // MARK: - Brand colors

    /// The main pink/magenta brand color, sampled from the gym's logo.
    static let brandPink = Color(red: 0.85, green: 0.14, blue: 0.52)

    /// A softer purple used for "paid / upcoming" calendar days and accents.
    static let accentPurple = Color(red: 0.47, green: 0.36, blue: 0.72)

    // MARK: - Status colors (used on the Calendar screen)

    /// A class the child actually attended (checked in).
    static let attended = Color(red: 0.30, green: 0.70, blue: 0.40)

    /// A future/today class that IS covered by a paid, active package.
    static let paid = accentPurple

    /// A future/today class that is NOT covered by any paid package yet.
    static let unpaid = Color(red: 0.95, green: 0.55, blue: 0.20)

    /// A past class day the child was scheduled for but did not attend.
    static let missed = Color(red: 0.6, green: 0.6, blue: 0.62)

    // MARK: - Neutral surface colors

    /// Page background color (soft off-white, matching the mockups).
    static let background = Color(red: 0.96, green: 0.96, blue: 0.97)

    /// White card background used for the QR card, table rows, etc.
    static let card = Color.white

    // MARK: - Shared metrics

    static let cardCornerRadius: CGFloat = 28
    static let smallCornerRadius: CGFloat = 12

    // MARK: - Shared fonts

    /// The blocky, monospaced-looking font used for names/headings in the mockups.
    static func nameFont(_ size: CGFloat = 22) -> Font {
        .system(size: size, weight: .bold, design: .monospaced)
    }
}
