//
//  ProfileView.swift
//
//  Screen 1: the child's account / QR check-in screen. This matches the
//  "First screen" mockup: name + logo up top, a photo, a white card with
//  the child's name + QR code + today's session time, and a pill below
//  showing how many paid classes are left this month.
//
//  It also contains the PROFILE SWITCHER (a menu) requested in the specs,
//  for parents with more than one kid — the mockup only shows one kid, so
//  this control is a small addition placed right next to the child's name.
//

import SwiftUI
import SwiftData

struct ProfileView: View {

    // Reads every saved child straight from the local database.
    @Query(sort: \ChildProfile.name) private var children: [ChildProfile]

    // Shared with the other tabs so switching kids here updates them too.
    @EnvironmentObject private var selectedChildStore: SelectedChildStore

    /// The child currently shown on screen.
    private var currentChild: ChildProfile? {
        ChildSelection.currentChild(in: children, selectedID: selectedChildStore.selectedChildID)
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            watermark

            if let child = currentChild {
                content(for: child)
            } else {
                // Only happens if the database is empty (no children saved yet).
                Text("No child profiles yet.")
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Main content

    private func content(for child: ChildProfile) -> some View {
        VStack(spacing: 20) {

            topBar(child: child)

            Spacer(minLength: 10)

            // The photo + white card are layered so the photo overlaps
            // the top edge of the card, like in the mockup.
            ZStack(alignment: .top) {
                qrCard(child: child)
                avatar(for: child)
                    .offset(y: -44)
            }
            .padding(.top, 44) // room for the avatar poking above the card

            classesRemainingPill(child: child)

            Spacer()
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Top bar (name + profile switcher + logo)

    private func topBar(child: ChildProfile) -> some View {
        HStack {
            // Tapping the name opens the profile switcher menu, letting a
            // parent with multiple kids change which child is shown.
            Menu {
                ForEach(children) { kid in
                    Button {
                        selectedChildStore.selectedChildID = kid.id
                    } label: {
                        if kid.id == child.id {
                            Label(kid.name, systemImage: "checkmark")
                        } else {
                            Text(kid.name)
                        }
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Text(child.name)
                        .font(Theme.nameFont())
                        .foregroundStyle(.black)
                    // Only show the "switch profile" chevron when there is
                    // actually more than one child to switch between.
                    if children.count > 1 {
                        Image(systemName: "chevron.down")
                            .font(.footnote.bold())
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Image("GymLogo")
                .resizable()
                .scaledToFit()
                .frame(height: 46)
        }
        .padding(.top, 8)
    }

    // MARK: - Avatar (photo placeholder)

    private func avatar(for child: ChildProfile) -> some View {
        // The mockup uses a real photo of the child; we use a simple
        // placeholder avatar instead since no photo is provided/stored.
        RoundedRectangle(cornerRadius: 16)
            .fill(Theme.brandPink.gradient)
            .frame(width: 88, height: 88)
            .overlay(
                Image(systemName: "figure.gymnastics")
                    .font(.system(size: 36))
                    .foregroundStyle(.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white, lineWidth: 4)
            )
            .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
    }

    // MARK: - White QR card

    private func qrCard(child: ChildProfile) -> some View {
        VStack(spacing: 14) {
            Spacer().frame(height: 44) // leaves room for the avatar overlap above

            Text(child.name)
                .font(Theme.nameFont(20))

            if let qrImage = QRCodeGenerator.image(for: child.qrCodeValue) {
                qrImage
                    .interpolation(.none) // keeps QR edges crisp, not blurry
                    .resizable()
                    .scaledToFit()
                    .frame(width: 190, height: 190)
            }

            VStack(spacing: 2) {
                Text("Your QR code to check-in")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 4) {
                    Text(todaySessionCaption(for: child))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .multilineTextAlignment(.center)

            Spacer().frame(height: 6)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                .fill(Theme.card)
                .shadow(color: .black.opacity(0.08), radius: 12, y: 6)
        )
    }

    /// "Today session at 15:30" or a friendly fallback if there is no
    /// class today for this child's age group (e.g. it's a Sunday).
    private func todaySessionCaption(for child: ChildProfile) -> String {
        let weekday = Calendar.current.component(.weekday, from: Date())
        if let session = MasterSchedule.session(for: child.ageGroup, weekday: weekday) {
            return "Today session at \(session.startTimeText)"
        } else {
            return "No class scheduled today"
        }
    }

    // MARK: - "X of Y classes remaining" pill

    private func classesRemainingPill(child: ChildProfile) -> some View {
        VStack(spacing: 2) {
            if let package = child.activePackage {
                HStack(spacing: 4) {
                    Text("\(child.classesRemainingInActivePackage)")
                        .font(.title.bold())
                        .foregroundStyle(Theme.brandPink)
                    Text("of \(package.totalClasses)")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                Text("classes remaining")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                Text("No active package")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.smallCornerRadius)
                .stroke(Theme.brandPink.opacity(0.5), lineWidth: 1.5)
        )
    }

    // MARK: - Background watermark

    private var watermark: some View {
        Image("BallerinaWatermark")
            .resizable()
            .renderingMode(.template) // lets us tint the artwork gray/faint
            .scaledToFit()
            .foregroundStyle(.gray.opacity(0.18))
            .frame(width: 260)
            .offset(x: 60, y: -180)
            .allowsHitTesting(false)
    }
}

#Preview {
    RootView()
        .modelContainer(for: [ChildProfile.self, Package.self, AttendanceRecord.self], inMemory: true)
}
