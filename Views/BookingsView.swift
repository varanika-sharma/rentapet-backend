//
//  BookingsView.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 1/5/26.
//
import SwiftUI

struct BookingsView: View {
    @EnvironmentObject private var authStore: AuthStore

    @State private var myBookings: [BookingWithPet] = []
    @State private var bookingsForMyPets: [BookingWithPet] = []

    @State private var isLoading = false
    @State private var errorText: String?

    var body: some View {
        List {
            if let errorText {
                Text(errorText)
                    .foregroundColor(.red)
            }

            if isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }

            Section("My Bookings") {
                if myBookings.isEmpty && !isLoading {
                    Text("No bookings yet.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(myBookings) { item in
                        NavigationLink {
                            BookingDetailView(booking: item)   // <-- must match your detail view’s init label
                        } label: {
                            BookingRow(booking: item)
                        }
                    }
                }
            }

            Section("Requests for My Pets") {
                if bookingsForMyPets.isEmpty && !isLoading {
                    Text("No requests yet.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(bookingsForMyPets) { item in
                        NavigationLink {
                            BookingDetailView(booking: item)   // <-- must match your detail view’s init label
                        } label: {
                            BookingRow(booking: item)
                        }
                    }
                }
            }
        }
        .navigationTitle("Bookings")
        .task { await load() }
        .refreshable { await load() }
    }

    private func load() async {
        guard let token = authStore.accessToken,
              let uid = authStore.userId else {
            errorText = "Please log in again."
            return
        }

        isLoading = true
        errorText = nil

        do {
            async let renterBookings = BookingsAPI.fetchMyBookings(accessToken: token, renterId: uid)
            async let ownerBookings  = BookingsAPI.fetchBookingsForMyPets(accessToken: token, ownerId: uid)

            let (renter, owner) = try await (renterBookings, ownerBookings)

            // Option B: join locally by fetching pets
            let pets = try await PetsAPI.fetchPets(accessToken: token)
            let petMap = Dictionary(uniqueKeysWithValues: pets.map { ($0.id, $0) })

            myBookings = renter.compactMap { b in
                guard let pet = petMap[b.petId] else { return nil }
                return BookingWithPet(booking: b, pet: pet)
            }
            .sorted { ($0.booking.createdAt ?? .distantPast) > ($1.booking.createdAt ?? .distantPast) }

            bookingsForMyPets = owner.compactMap { b in
                guard let pet = petMap[b.petId] else { return nil }
                return BookingWithPet(booking: b, pet: pet)
            }
            .sorted { ($0.booking.createdAt ?? .distantPast) > ($1.booking.createdAt ?? .distantPast) }

        } catch {
            errorText = error.localizedDescription
        }

        isLoading = false
    }
}
