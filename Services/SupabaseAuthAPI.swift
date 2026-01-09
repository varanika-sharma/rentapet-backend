//
//  SupabaseAuthAPI.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 12/31/25.
//

import Foundation

enum SupabaseAuthAPI {

    static func signUp(email: String, password: String) async throws -> SupabaseSession {
        let payload: [String: Any] = [
            "email": email,
            "password": password
        ]
        let body = try JSONSerialization.data(withJSONObject: payload, options: [])

        let (data, _) = try await SupabaseHTTP.request(
            method: "POST",
            baseURL: SupabaseConfig.url.absoluteString,
            path: "/auth/v1/signup",
            headers: [
                "apikey": SupabaseConfig.anonKey
            ],
            queryItems: [],
            body: body
        )

        return try SupabaseJSON.decoder().decode(SupabaseSession.self, from: data)

    }

    static func signIn(email: String, password: String) async throws -> SupabaseSession {
        let payload: [String: Any] = [
            "email": email,
            "password": password
        ]
        let body = try JSONSerialization.data(withJSONObject: payload, options: [])

        let (data, _) = try await SupabaseHTTP.request(
            method: "POST",
            baseURL: SupabaseConfig.url.absoluteString,
            path: "/auth/v1/token",
            headers: [
                "apikey": SupabaseConfig.anonKey
            ],
            queryItems: [URLQueryItem(name: "grant_type", value: "password")],
            body: body
        )

        return try SupabaseJSON.decoder().decode(SupabaseSession.self, from: data)
    }
}
