//
//  BookingsAPI.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 12/31/25.
//

// If you don't already have it, this is the matching API shape that returns a booking id.
// Put this in BookingsAPI.swift (or adjust to match your existing file).

import Foundation

enum BookingsAPI {



    // MARK: - Row type used when embedding the Pet object
    private struct BookingRow: Codable {
        let id: UUID
        let petId: UUID
        let renterId: UUID
        let startDate: Date
        let endDate: Date
        let totalPrice: Double
        let status: String
        let createdAt: Date?
        let pet: Pet?

        enum CodingKeys: String, CodingKey {
            case id
            case petId = "pet_id"
            case renterId = "renter_id"
            case startDate = "start_date"
            case endDate = "end_date"
            case totalPrice = "total_price"
            case status
            case createdAt = "created_at"
            case pet // comes from select alias: pet:pets(...)
        }

        var booking: Booking {
            Booking(
                id: id,
                petId: petId,
                renterId: renterId,
                startDate: startDate,
                endDate: endDate,
                totalPrice: totalPrice,
                status: status,
                createdAt: createdAt,
                addOns: []
            )
        }
    }

    // MARK: - Create booking request
    // Option 2 pattern: return representation so we can get the created booking id.
    static func createBookingRequest(
        accessToken: String,
        petId: UUID,
        renterId: UUID,
        startDate: Date,
        endDate: Date,
        totalPrice: Double
    ) async throws -> Booking {

        let headers: [String: String] = [
            "apikey": SupabaseConfig.anonKey,
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json",
            "Prefer": "return=representation"
        ]

        let bodyDict: [String: Any] = [
            "pet_id": petId.uuidString,
            "renter_id": renterId.uuidString,
            "start_date": ISO8601DateFormatter().string(from: startDate),
            "end_date": ISO8601DateFormatter().string(from: endDate),
            "total_price": totalPrice,
            "status": "pending"
        ]

        let bodyData = try JSONSerialization.data(withJSONObject: bodyDict, options: [])

        let (data, _) = try await SupabaseHTTP.request(
            method: "POST",
            baseURL: SupabaseConfig.url.absoluteString,
            path: "/rest/v1/bookings",
            headers: headers,
            queryItems: [],
            body: bodyData
        )

        // Supabase returns an ARRAY when using return=representation
        let bookings = try JSONDecoder().decode([Booking].self, from: data)

        guard let booking = bookings.first else {
            throw NSError(domain: "BookingsAPI", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Booking created but no row returned."
            ])
        }

        return booking
    }





    // MARK: - My bookings (I am the renter)
    static func fetchMyBookings(
        accessToken: String,
        renterId: UUID
    ) async throws -> [Booking] {

        let headers: [String: String] = [
            "apikey": SupabaseConfig.anonKey,
            "Authorization": "Bearer \(accessToken)"
        ]

        let queryItems = [
            URLQueryItem(name: "renter_id", value: "eq.\(renterId.uuidString)"),
            URLQueryItem(name: "select", value: "*,add_ons(*)")
        ]

        let (data, _) = try await SupabaseHTTP.request(
            method: "GET",
            baseURL: SupabaseConfig.url.absoluteString,
            path: "/rest/v1/bookings",
            headers: headers,
            queryItems: queryItems
        )
        return try SupabaseJSON.decoder().decode([Booking].self, from: data)

    }

    // MARK: - Bookings for pets I own (I am the owner)
    static func fetchBookingsForMyPets(
        accessToken: String,
        ownerId: UUID
    ) async throws -> [Booking] {

        let headers: [String: String] = [
            "apikey": SupabaseConfig.anonKey,
            "Authorization": "Bearer \(accessToken)"
        ]

        let queryItems = [
            URLQueryItem(
                name: "select",
                value: "*,add_ons(*),pets!inner(owner_id)"
            ),
            URLQueryItem(
                name: "pets.owner_id",
                value: "eq.\(ownerId.uuidString)"
            )
        ]

        let (data, _) = try await SupabaseHTTP.request(
            method: "GET",
            baseURL: SupabaseConfig.url.absoluteString,
            path: "/rest/v1/bookings",
            headers: headers,
            queryItems: queryItems
        )

        return try SupabaseJSON.decoder().decode([Booking].self, from: data)

    }

    // MARK: - Helpers
    private static func iso8601String(_ date: Date) -> String {
        // Supabase/Postgres accepts ISO8601 timestamps.
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }
}
