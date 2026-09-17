//
//  PaymentLogView.swift
//
//  Screen 3: shows the child's currently active package plus a history of
//  previously purchased packages, as a simple 3-column list (Payment date /
//  Package / End date) — matching the "Third screen" mockup.
//
//  This screen is READ-ONLY: it just displays packages that were already
//  recorded (in this local-only demo, that means the sample data created
//  in SampleData.swift). There is no in-app purchase flow, since the specs
//  described this as a log/record for the parent to check, not a checkout.
//

import SwiftUI
import SwiftData

struct PaymentLogView: View {

    @Query(sort: \ChildProfile.name) private var children: [ChildProfile]
    @EnvironmentObject private var selectedChildStore: SelectedChildStore

    private var currentChild: ChildProfile? {
        ChildSelection.currentChild(in: children, selectedID: selectedChildStore.selectedChildID)
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            watermark

            if let child = currentChild {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        topBar(child: child)
                        columnHeaders

                        sectionTitle("Active package:")
                        if let active = child.activePackage {
                            PackageRow(package: active)
                        } else {
                            Text("No active package")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        sectionTitle("History packages:")
                        ForEach(child.historyPackages) { package in
                            PackageRow(package: package)
                        }
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

    // MARK: - Top bar (name + logo)

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

    // MARK: - Column headers ("Payment date | Package | End date")

    private var columnHeaders: some View {
        HStack {
            Text("Payment date").frame(maxWidth: .infinity, alignment: .leading)
            Text("Package").frame(maxWidth: .infinity, alignment: .leading)
            Text("End date").frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.title3.bold())
            .padding(.top, 4)
    }

    // MARK: - Background watermark

    private var watermark: some View {
        Image("BallerinaWatermark")
            .resizable()
            .renderingMode(.template)
            .scaledToFit()
            .foregroundStyle(.gray.opacity(0.16))
            .frame(width: 240)
            .offset(x: 40, y: -100)
            .allowsHitTesting(false)
    }
}

/// One row in the payment table: purchase date / class count / end date.
private struct PackageRow: View {
    let package: Package

    var body: some View {
        HStack {
            Text(formatted(package.purchaseDate)).frame(maxWidth: .infinity, alignment: .leading)
            Text("\(package.totalClasses) classes").frame(maxWidth: .infinity, alignment: .leading)
            Text(formatted(package.endDate)).frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.body)
    }

    /// Formats a date as "12 Sep", matching the mockup's date style.
    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: date)
    }
}

#Preview {
    RootView()
        .modelContainer(for: [ChildProfile.self, Package.self, AttendanceRecord.self], inMemory: true)
}
