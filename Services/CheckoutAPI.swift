//
//  CheckoutAPI.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 12/29/25.
//

import Foundation

struct CheckoutResponse: Decodable {
    let paymentIntentClientSecret: String
}

final class CheckoutAPI {
    // iOS Simulator talks to your Mac via localhost
    private let baseURL = URL(string: "https://rentapet-backend.onrender.com")!

    func createPaymentIntent(amountInCents: Int, currency: String = "usd") async throws -> CheckoutResponse {
        var request = URLRequest(url: baseURL.appendingPathComponent("/create-payment-intent"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "amount": amountInCents,
            "currency": currency
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse,
           !(200...299).contains(http.statusCode) {

            let text = String(data: data, encoding: .utf8) ?? ""
            throw NSError(
                domain: "CheckoutAPI",
                code: http.statusCode,
                userInfo: [
                    NSLocalizedDescriptionKey: "Backend error (\(http.statusCode)): \(text)"
                ]
            )
        }

        return try SupabaseJSON.decoder().decode(CheckoutResponse.self, from: data)
    }
}
