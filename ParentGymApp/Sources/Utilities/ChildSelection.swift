//
//  ChildSelection.swift
//
//  A tiny shared helper used by all 3 tabs to figure out "which child
//  should this screen show right now?" — either the one explicitly picked
//  in the profile switcher, or simply the first child on file if nothing
//  has been picked yet (e.g. right after the app first launches).
//

import Foundation

enum ChildSelection {
    static func currentChild(in children: [ChildProfile], selectedID: UUID?) -> ChildProfile? {
        if let selectedID, let match = children.first(where: { $0.id == selectedID }) {
            return match
        }
        return children.first
    }
}
