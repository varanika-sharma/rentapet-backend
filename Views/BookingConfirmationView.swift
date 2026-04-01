//
//  BookingConfirmationView.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 12/23/25.
//
import SwiftUI

struct BookingConfirmationView: View {
    let booking: BookingWithPet

    @EnvironmentObject private var appState: AppState

    private var dateRangeText: String {
        let df = DateFormatter()
        df.dateStyle = .medium
        return "\(df.string(from: booking.booking.startDate)) → \(df.string(from: booking.booking.endDate))"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 72))
                    .foregroundColor(.green)

                Text("Request Sent")
                    .font(.title)
                    .fontWeight(.bold)

                Text("You requested \(booking.pet.name)")
                    .font(.headline)

                Text(dateRangeText)
                    .foregroundColor(.secondary)

                GroupBox("Summary") {
                    VStack(spacing: 8) {
                        HStack {
                            Text("Total")
                            Spacer()
                            Text("$\(booking.booking.totalPrice, specifier: "%.2f")")
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.accent)
                        }

                        HStack {
                            Text("Status")
                            Spacer()
                            Text(booking.booking.status)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Button {
                    appState.selectedTabIndex = 1
                    appState.homePath = NavigationPath()
                    appState.bookingsPath = NavigationPath()
                } label: {
                    Text("View My Bookings")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.primary)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
                .padding(.top, 8)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }
}
