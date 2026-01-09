//
//  PetsAPI.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 12/31/25.
//

import Foundation

enum PetsAPI {

    static func fetchPets(accessToken: String?) async throws -> [Pet] {
        var headers: [String: String] = [
            "apikey": SupabaseConfig.anonKey
        ]

        // Only include Authorization if we have a token
        if let accessToken {
            headers["Authorization"] = "Bearer \(accessToken)"
        }

        let (data, _) = try await SupabaseHTTP.request(
            method: "GET",
            baseURL: SupabaseConfig.url.absoluteString,
            path: "/rest/v1/pets",
            headers: headers,
            queryItems: [
                URLQueryItem(name: "select", value: "*"),
                URLQueryItem(name: "order", value: "created_at.desc")
            ]
        )

        return try SupabaseJSON.decoder().decode([Pet].self, from: data)
    }



    static func createPet(
        accessToken: String,
        ownerId: String,
        name: String,
        type: String,
        age: Int,
        pricePerDay: Double,
        description: String
    ) async throws {

        let payload: [String: Any] = [
            "owner_id": ownerId,
            "name": name,
            "type": type,
            "age": age,
            "price_per_day": pricePerDay,
            "description": description,
            "image_urls": [],
            "image_name": NSNull()
        ]

        let body = try JSONSerialization.data(withJSONObject: payload, options: [])

        let headers: [String: String] = [
            "apikey": SupabaseConfig.anonKey,
            "Authorization": "Bearer \(accessToken)",
            "Prefer": "return=minimal"
        ]

        _ = try await SupabaseHTTP.request(
            method: "POST",
            baseURL: SupabaseConfig.url.absoluteString,
            path: "/rest/v1/pets",
            headers: headers,
            queryItems: [],
            body: body
        )
    }
}

