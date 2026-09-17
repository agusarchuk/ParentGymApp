//
//  SelectedChildStore.swift
//
//  A tiny shared piece of state that remembers which child is currently
//  selected in the profile switcher (on the Profile tab). It is shared
//  with the Calendar and Payment Log tabs (via `.environmentObject`) so
//  that switching the child on one tab updates all three screens.
//

import Foundation
import Combine

@MainActor
final class SelectedChildStore: ObservableObject {
    /// The id of the currently selected child, or nil if none has been
    /// picked yet (in which case screens fall back to "the first child").
    @Published var selectedChildID: UUID?
}
