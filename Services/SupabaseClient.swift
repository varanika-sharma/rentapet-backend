//
//  SupabaseClient.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 12/31/25.
//

import Foundation

enum SupabaseREST {
    static func request(
        _ path: String,
        method: String = "GET",
        accessToken: String? = nil,
        queryItems: [URLQueryItem] = [],
        jsonBody: Any? = nil
    ) async throws -> (Data, HTTPURLResponse) {

        var url = Config.supabaseURL
        url.append(path: path)

        if !queryItems.isEmpty {
            var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            comps.queryItems = queryItems
            url = comps.url!
        }

        var req = URLRequest(url: url)
        req.httpMethod = method

        req.setValue(Config.supabaseAnonKey, forHTTPHeaderField: "apikey")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let accessToken {
            req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        if let jsonBody {
            req.httpBody = try JSONSerialization.data(withJSONObject: jsonBody)
        }

        let (data, resp) = try await URLSession.shared.data(for: req)

        guard let http = resp as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if !(200...299).contains(http.statusCode) {
            // helpful error string
            let msg = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "SupabaseHTTP", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: msg])
        }

        return (data, http)
    }
}
