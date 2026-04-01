//
//  Booking.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 12/24/25.
//

import Foundation

struct Booking: Identifiable, Codable, Hashable {
    let id: UUID
    let petId: UUID
    let renterId: UUID
    let startDate: Date
    let endDate: Date
    let totalPrice: Double
    let status: String
    let createdAt: Date?

    // ✅ ADD THIS
    let addOns: [BookingAddOn]

    enum CodingKeys: String, CodingKey {
        case id
        case petId = "pet_id"
        case renterId = "renter_id"
        case startDate = "start_date"
        case endDate = "end_date"
        case totalPrice = "total_price"
        case status
        case createdAt = "created_at"
        case addOns = "add_ons"
    }
}

