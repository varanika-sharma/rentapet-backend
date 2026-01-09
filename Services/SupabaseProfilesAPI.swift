//
//  SupabaseProfilesAPI.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 12/31/25.
//

import Foundation

enum SupabaseProfilesAPI {

    static func upsertProfile(accessToken: String, userId: String, name: String) async throws {
        let payload: [String: Any] = [
            "id": userId,
            "name": name
        ]
        let body = try JSONSerialization.data(withJSONObject: payload, options: [])

        _ = try await SupabaseHTTP.request(
            method: "POST",
            baseURL: SupabaseConfig.url.absoluteString,
            path: "/rest/v1/profiles",
            headers: [
                "apikey": SupabaseConfig.anonKey,
                "Authorization": "Bearer \(accessToken)",
                "Prefer": "resolution=merge-duplicates"
            ],
            queryItems: [URLQueryItem(name: "on_conflict", value: "id")],
            body: body
        )
    }
}
