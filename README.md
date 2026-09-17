# Gym Tracker (parent app)

A simple, local-only iOS app (Swift + SwiftUI + SwiftData) for a parent to
track their kid(s)' gymnastics class attendance, package/payment history,
and show a QR code to check in — for the "Funtastic Gymnastic" kids classes.

Everything is stored **on the phone only** (SwiftData/local database) —
there is no server, network call, or login anywhere in this project.

## What's inside

```
Sources/
  GymTrackerApp.swift          - app entry point, sets up the local database
  Theme/Theme.swift            - all colors/fonts in one place
  Models/                      - the 3 things we store locally
    ChildProfile.swift          (a kid: name, age group, QR code)
    Package.swift                (a purchased pass: dates + class count)
    AttendanceRecord.swift      (one day the child checked in, or not)
  Services/
    MasterSchedule.swift        - the gym's real weekly class schedule
    CalendarDayStatus.swift     - the rule that colors each calendar day
    QRCodeGenerator.swift       - turns text into a QR code image
    SampleData.swift             - creates example data on first launch
    SelectedChildStore.swift    - remembers which kid is picked (shared across tabs)
  Utilities/                    - small date/calendar helper functions
  Views/
    RootView.swift               - the 3-tab bar
    Profile/ProfileView.swift    - Screen 1: QR check-in + profile switcher
    Calendar/CalendarView.swift  - Screen 2: month calendar
    Payments/PaymentLogView.swift - Screen 3: active + past packages
  Assets.xcassets/              - the gym's real logo + ballerina artwork
project.yml                      - lets you generate the .xcodeproj automatically
```

## How to open this in Xcode

**Option A — Easiest (recommended): use XcodeGen**

1. Install XcodeGen once, if you don't have it: `brew install xcodegen`
2. In Terminal, `cd` into this `GymTracker` folder.
3. Run: `xcodegen generate`
4. Open the newly created `GymTracker.xcodeproj` in Xcode and press ▶️ Run.

**Option B — No XcodeGen, do it by hand in Xcode**

1. In Xcode: File ▸ New ▸ Project ▸ iOS ▸ App. Name it `GymTracker`,
   Interface: SwiftUI, Storage: SwiftData, minimum iOS 17.
2. In Finder, delete the placeholder `ContentView.swift` and the default
   `Item.swift` Xcode created for you, and delete the default empty
   `Assets.xcassets` it created.
3. Drag the entire `Sources` folder from this download into your new
   Xcode project (check "Copy items if needed").
4. Build and run.

## Key decisions / assumptions made while building this

The written brief left a few specifics open to interpretation. Here's what
was assumed, and why — happy to change any of these:

- **Local-only storage**: per your instruction, everything is saved with
  SwiftData directly on the phone. No backend/API integration exists yet,
  but the code is organized (Models / Services / Views) so a real backend
  could be swapped in later without a rewrite.
- **Payment Log is read-only**: the app displays packages, it doesn't sell
  them. In a real gym, packages would be recorded by staff/admin when a
  parent pays in person — since there's no such counterpart system here,
  example packages are seeded automatically on first launch (see below).
- **Attendance is also read-only** for the same reason: normally staff scan
  the child's QR code at the front desk to check them in. This parent app
  only *displays* that history; it doesn't have a way to mark attendance
  itself.
- **Calendar color rule**: a day is `attended` (green) if there's a
  check-in record for it; otherwise `missed` (gray) if it's in the past;
  otherwise (today/future) `paid` (purple) if an active package's date
  range covers that day, or `unpaid` (orange) if not. Only days matching
  the child's own age-group class schedule are highlighted at all — every
  other day is shown plain, matching "days of chosen age group" from the
  brief.
- **Packages run by calendar month** (e.g. 1–30 Sept), matching "classes
  left this month" from the brief, rather than a rolling 30-day window.
- **The weekly class schedule** (which age group has class on which
  weekday, and at what time) was transcribed directly from the
  "Class Schedule 2026–2027" flyer image you provided, into
  `MasterSchedule.swift`. If the real schedule ever changes, that's the
  one file to edit.
- **Child photo**: the mockup shows a real photo of a child; a generic
  colored placeholder icon is used instead here, since no actual photo
  asset was provided. Wiring up a real photo (from the camera roll or a
  future backend) would be a small follow-up.
- **Sample data**: since there's no backend, two example kids ("Ana Smith"
  and "Leo Smith", matching the mockup's name and demonstrating the
  profile switcher) are created automatically the first time the app
  runs, with a realistic mix of attended/missed/paid/unpaid days so every
  screen has something meaningful to show immediately.
