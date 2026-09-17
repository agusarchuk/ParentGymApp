//
//  GymTrackerApp.swift
//  GymTracker
//
//  This is the entry point of the app (the "@main" struct is where iOS
//  starts running our code). Its only two jobs are:
//   1) Set up the local on-device database ("model container") that
//      SwiftData will use to store children, packages and attendance.
//   2) Show our RootView (the tab bar with the 3 screens).
//
//  Everything is stored locally on the phone — there is no server/network
//  code anywhere in this project. SwiftData automatically saves the data
//  into a small database file inside the app's own sandboxed storage.
//

import SwiftUI
import SwiftData

@main
struct GymTrackerApp: App {

    // SwiftData needs to know which model types it will be storing.
    // We list every "@Model" class from the Models folder here once.
    // Behind the scenes this creates (or opens, if it already exists)
    // a local SQLite database file on the device.
    let modelContainer: ModelContainer = {
        let schema = Schema([
            ChildProfile.self,
            Package.self,
            AttendanceRecord.self
        ])

        // isStoredInMemoryOnly: false  -> data survives app restarts.
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            // If the database can't be created something is seriously wrong
            // (e.g. disk full). Crashing here with a clear message is better
            // than silently continuing with a broken app.
            fatalError("Could not create the local SwiftData database: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                // Seed the database with example children/packages/attendance
                // the very first time the app is ever launched, so the demo
                // isn't empty. See SampleData.swift for details.
                .task {
                    SampleData.seedIfNeeded(context: modelContainer.mainContext)
                }
        }
        // Makes the database available to every view in the app via
        // the SwiftData @Query / @Environment(\.modelContext) machinery.
        .modelContainer(modelContainer)
    }
}
