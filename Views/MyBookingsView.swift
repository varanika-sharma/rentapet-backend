//
//  MyBookingsView.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 12/24/25.
//
import SwiftUI

struct MyBookingsView: View {
    @EnvironmentObject private var bookingsStore: BookingStore  // or whatever your store is called

    var body: some View {
        List {
            if bookingsStore.bookings.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("No bookings yet")
                        .font(.headline)
                    Text("Book a pet sitter and your reservations will show up here.")
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            } else {
                ForEach(bookingsStore.bookings, id: \.id) { booking in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(booking.status.capitalized)
                                .font(.headline)

                            Spacer()

                            Text("$\(booking.totalPrice, specifier: "%.2f")")
                                .fontWeight(.semibold)
                        }

                        Text(dateRangeText(start: booking.startDate, end: booking.endDate))
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .navigationTitle("My Bookings")
    }

    private func dateRangeText(start: Date, end: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        return "\(df.string(from: start)) → \(df.string(from: end))"
    }
}
