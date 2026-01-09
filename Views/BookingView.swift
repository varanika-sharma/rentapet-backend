//
//  BookingView.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 12/23/25.
//

import SwiftUI

struct BookingView: View {
    let pet: Pet

    @EnvironmentObject private var authStore: AuthStore
    @Environment(\.dismiss) private var dismiss

    @State private var startDate: Date = Date()
    @State private var endDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()

    @State private var errorText: String?
    @State private var isSubmitting = false

    // ✅ triggers navigation
    @State private var createdBooking: BookingWithPet?

    private var minEndDate: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: startDate) ?? startDate
    }

    private var numberOfDays: Int {
        let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        return max(days, 1)
    }

    private var totalPrice: Double {
        Double(numberOfDays) * pet.pricePerDay
    }

    var body: some View {
        VStack(spacing: 16) {

            VStack(alignment: .leading, spacing: 6) {
                Text("Request \(pet.name)")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("$\(pet.pricePerDay, specifier: "%.0f") / day")
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            GroupBox("Dates") {
                VStack(spacing: 12) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                        .onChange(of: startDate) { _, _ in
                            if endDate < minEndDate { endDate = minEndDate }
                        }

                    DatePicker("End Date", selection: $endDate, in: minEndDate..., displayedComponents: .date)
                }
            }

            GroupBox("Summary") {
                HStack {
                    Text("Days")
                    Spacer()
                    Text("\(numberOfDays)")
                        .fontWeight(.semibold)
                }

                Divider().padding(.vertical, 6)

                HStack {
                    Text("Total")
                    Spacer()
                    Text("$\(totalPrice, specifier: "%.0f")")
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.accent)
                }
            }

            if let errorText {
                Text(errorText)
                    .foregroundColor(.red)
                    .font(.subheadline)
            }

            Spacer()

            Button {
                Task { await submit() }
            } label: {
                HStack {
                    if isSubmitting { ProgressView() }
                    Text(isSubmitting ? "Submitting…" : "Request Booking")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppTheme.primary)
                .foregroundColor(.white)
                .cornerRadius(16)
            }
            .disabled(isSubmitting)

            Button("Cancel") { dismiss() }
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
        .padding()
        .navigationTitle("Booking")
        .navigationBarTitleDisplayMode(.inline)

        // ✅ push confirmation when set
        .navigationDestination(item: $createdBooking) { bookingWithPet in
            BookingConfirmationView(booking: bookingWithPet)
        }
    }

    private func submit() async {
        guard let token = authStore.accessToken,
              let renterId = authStore.userId else {
            await MainActor.run { errorText = "Please log in again." }
            return
        }

        if renterId == pet.ownerId {
            await MainActor.run { errorText = "You can’t book your own pet." }
            return
        }

        if endDate < minEndDate {
            await MainActor.run { errorText = "End date must be at least 1 day after start date." }
            return
        }

        await MainActor.run {
            isSubmitting = true
            errorText = nil
        }

        do {
            let booking = try await BookingsAPI.createBookingRequest(
                accessToken: token,
                petId: pet.id,
                renterId: renterId,
                startDate: startDate,
                endDate: endDate,
                totalPrice: totalPrice
            )

            let withPet = BookingWithPet(booking: booking, pet: pet)

            await MainActor.run {
                createdBooking = withPet
                isSubmitting = false
            }
        } catch {
            await MainActor.run {
                errorText = error.localizedDescription
                isSubmitting = false
            }
        }
    }
}
