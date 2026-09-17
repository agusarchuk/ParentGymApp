//
//  RootView.swift
//
//  The app's root screen. This is just a 3-tab bar, matching the
//  requirement that the bottom bar's 3 items are:
//    1) Profile switcher  -> the child's account/QR check-in screen,
//       which also contains the picker for switching between kids.
//    2) Calendar           -> this month's schedule.
//    3) Payment log         -> active package + purchase history.
//

import SwiftUI

struct RootView: View {

    // This one object is shared between all 3 tabs (see SelectedChildStore)
    // so that picking a different kid on the Profile tab immediately
    // updates what the Calendar and Payment Log tabs show too.
    @StateObject private var selectedChildStore = SelectedChildStore()

    var body: some View {
        TabView {
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }

            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }

            PaymentLogView()
                .tabItem {
                    Label("Payments", systemImage: "creditcard")
                }
        }
        .environmentObject(selectedChildStore)
        .tint(Theme.brandPink) // colors the selected tab icon/text
    }
}
