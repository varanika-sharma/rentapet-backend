//
//  SupabaseHTTP.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 1/2/26.
//

import Foundation

enum SupabaseHTTP {
    struct HTTPError: Error, LocalizedError {
        let statusCode: Int
        let body: String

        var errorDescription: String? {
            "HTTP \(statusCode): \(body)"
        }
    }

    /// Generic HTTP request helper for Supabase REST/Auth endpoints
    static func request(
        method: String,
        baseURL: String,
        path: String,
        headers: [String: String] = [:],
        queryItems: [URLQueryItem] = [],
        body: Data? = nil
    ) async throws -> (Data, HTTPURLResponse) {

        guard var components = URLComponents(string: baseURL) else {
            throw URLError(.badURL)
        }

        // Ensure path concatenation works
        let cleanBasePath = components.path
        let cleanPath = path.hasPrefix("/") ? path : "/\(path)"
        components.path = cleanBasePath + cleanPath

        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let url = components.url else { throw URLError(.badURL) }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body

        // Default headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Custom headers
        headers.forEach { k, v in
            request.setValue(v, forHTTPHeaderField: k)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if !(200...299).contains(http.statusCode) {
            let bodyString = String(data: data, encoding: .utf8) ?? ""
            throw HTTPError(statusCode: http.statusCode, body: bodyString)
        }

        return (data, http)
    }
}
