//
//  Pet.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 12/23/25.
//
import Foundation

struct Pet: Identifiable, Hashable, Codable {
    let id: UUID
    let ownerId: UUID
    let name: String
    let type: String
    let age: Int
    let pricePerDay: Double
    let description: String
    let imageURLs: [String]

    // Temporary local fallback image name (optional)
    let imageName: String?

    enum CodingKeys: String, CodingKey {
        case id
        case ownerId = "owner_id"
        case name
        case type
        case age
        case pricePerDay = "price_per_day"
        case description
        case imageURLs = "image_urls"
        case imageName = "image_name"
    }
}
