//
//  BookingAddOn.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 1/5/26.
//

import Foundation

struct BookingAddOn: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let pricePerDay: Double

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case pricePerDay = "price_per_day"
    }
}
