//
//  AddOn.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 12/24/25.
//
import Foundation

struct AddOn: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    let price: Double
}
