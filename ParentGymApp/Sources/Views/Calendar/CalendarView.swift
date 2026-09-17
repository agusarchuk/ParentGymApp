//
//  CalendarView.swift
//
//  Screen 2: a month calendar that highlights, for the selected child's
//  own age group:
//    • days the child actually attended          -> green
//    • upcoming class days already paid for       -> purple
//    • upcoming class days NOT paid for yet        -> orange
//    • past class days the child missed             -> gray
//  All other days (not a class day for this child) are shown plain.
//
//  The exact coloring rule for each day lives in CalendarDayStatus.swift —
//  this file is only responsible for drawing the grid.
//

import SwiftUI
import SwiftData

struct CalendarView: View {

    @Query(sort: \ChildProfile.name) private var children: [ChildProfile]
    @EnvironmentObject private var selectedChildStore: SelectedChildStore

    /// Which month is currently being displayed. Starts on today's month.
    @State private var displayedMonth: Date = Date()

    private var currentChild: ChildProfile? {
        ChildSelection.currentChild(in: children, selectedID: selectedChildStore.selectedChildID)
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            watermark

            if let child = currentChild {
                ScrollView {
                    VStack(spacing: 20) {
                        topBar(child: child)
                        groupBadge(child: child)
                        monthNavigator
                        weekdayHeader
                        dayGrid(child: child)
                        legend
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            } else {
                Text("No child profiles yet.")
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Top bar (name + logo, same style as the other screens)

    private func topBar(child: ChildProfile) -> some View {
        HStack {
            Text(child.name)
                .font(Theme.nameFont())
            Spacer()
            Image("GymLogo")
                .resizable()
                .scaledToFit()
                .frame(height: 46)
        }
        .padding(.top, 8)
    }

    // MARK: - "3-4 yo · is your group" badge

    private func groupBadge(child: ChildProfile) -> some View {
        HStack(spacing: 8) {
            Text(child.ageGroup.shortLabel)
                .font(.subheadline.bold())
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.smallCornerRadius)
                        .stroke(.black.opacity(0.6), lineWidth: 1)
                )
            Text("is your group")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    // MARK: - Month navigation ("< September 2026 >")

    private var monthNavigator: some View {
        HStack {
            Button {
                shiftMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left.circle.fill")
            }

            Spacer()

            Text(Calendar.current.monthTitle(for: displayedMonth))
                .font(.headline)

            Spacer()

            Button {
                shiftMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right.circle.fill")
            }
        }
        .font(.title3)
        .foregroundStyle(Theme.brandPink)
    }

    private func shiftMonth(by value: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: displayedMonth) {
            displayedMonth = newMonth
        }
    }

    // MARK: - Weekday header row (Mon, Tue, ... Sun)

    private var weekdayHeader: some View {
        let labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        return HStack(spacing: 6) {
            ForEach(labels, id: \.self) { label in
                Text(label)
                    .font(.caption.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(white: 0.9))
                    )
            }
        }
    }

    // MARK: - The day grid itself

    private func dayGrid(child: ChildProfile) -> some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
        let days = Calendar.current.monthGridDays(containing: displayedMonth)

        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(Array(days.enumerated()), id: \.offset) { _, maybeDay in
                if let day = maybeDay {
                    DayCell(date: day, status: CalendarDayStatus.compute(for: day, child: child))
                } else {
                    // Empty filler cell so the 1st of the month lines up
                    // under the correct weekday column.
                    Color.clear.frame(height: 40)
                }
            }
        }
    }

    // MARK: - Color legend

    private var legend: some View {
        VStack(alignment: .leading, spacing: 8) {
            legendRow(color: Theme.attended, text: "Attended")
            legendRow(color: Theme.paid, text: "Upcoming class · paid")
            legendRow(color: Theme.unpaid, text: "Upcoming class · not paid yet")
            legendRow(color: Theme.missed, text: "Missed class")
        }
        .padding(.top, 8)
    }

    private func legendRow(color: Color, text: String) -> some View {
        HStack(spacing: 8) {
            Circle().fill(color).frame(width: 12, height: 12)
            Text(text).font(.caption).foregroundStyle(.secondary)
        }
    }

    // MARK: - Background watermark

    private var watermark: some View {
        Image("BallerinaWatermark")
            .resizable()
            .renderingMode(.template)
            .scaledToFit()
            .foregroundStyle(.gray.opacity(0.14))
            .frame(width: 220)
            .offset(x: -40, y: -260)
            .allowsHitTesting(false)
    }
}

/// One single day cell in the calendar grid: a colored rounded shape with
/// the day number on it (or a plain, unhighlighted number for days that
/// aren't a class day for this child at all).
private struct DayCell: View {
    let date: Date
    let status: CalendarDayStatus

    var body: some View {
        let dayNumber = Calendar.current.component(.day, from: date)

        RoundedRectangle(cornerRadius: 10)
            .fill(fillColor)
            .frame(height: 40)
            .overlay(
                Text("\(dayNumber)")
                    .font(.subheadline.weight(status == .notScheduled ? .regular : .bold))
                    .foregroundStyle(status == .notScheduled ? Color.primary : Color.white)
            )
    }

    private var fillColor: Color {
        switch status {
        case .notScheduled: return Color(white: 0.93)
        case .attended:      return Theme.attended
        case .paid:           return Theme.paid
        case .unpaid:         return Theme.unpaid
        case .missed:         return Theme.missed
        }
    }
}

#Preview {
    RootView()
        .modelContainer(for: [ChildProfile.self, Package.self, AttendanceRecord.self], inMemory: true)
}
