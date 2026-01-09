//
//  BookingRow.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 1/5/26.
//

import SwiftUI

struct BookingRow: View {
    let booking: BookingWithPet

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(booking.pet.name)
                .font(.headline)

            Text(dateRangeText(start: booking.booking.startDate, end: booking.booking.endDate))
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack {
                Text("Status: \(booking.booking.status)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text("$\(booking.booking.totalPrice, specifier: "%.0f")")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
        }
        .padding(.vertical, 6)
    }

    private func dateRangeText(start: Date, end: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        return "\(df.string(from: start)) – \(df.string(from: end))"
    }
}
