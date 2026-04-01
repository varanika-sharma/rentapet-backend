//
//  BookingDetailView.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 1/5/26.
//

import SwiftUI

struct BookingDetailView: View {
    let booking: BookingWithPet

    var body: some View {
        Form {
            Section("Pet") {
                Text(booking.pet.name)
                Text(booking.pet.type)
                    .foregroundColor(.secondary)
            }

            Section("Dates") {
                Text("Start: \(format(booking.booking.startDate))")
                Text("End: \(format(booking.booking.endDate))")
            }

            Section("Payment") {
                Text("Total: $\(booking.booking.totalPrice, specifier: "%.0f")")
            }

            Section("Status") {
                Text(booking.booking.status.capitalized)
            }
        }
        .navigationTitle("Booking")
    }

    private func format(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df.string(from: date)
    }
}
