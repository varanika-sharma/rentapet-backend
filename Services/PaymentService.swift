//
//  PaymentService.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 12/27/25.
//

import Foundation

protocol PaymentServicing {
    func pay(amount: Double) async -> Result<Void, Error>
}

struct MockPaymentService: PaymentServicing {
    func pay(amount: Double) async -> Result<Void, Error> {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_200_000_000)

        // 90% success, 10% failure (so you can test errors)
        if Int.random(in: 1...10) == 1 {
            return .failure(NSError(domain: "Payment", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Payment failed. Please try again."
            ]))
        } else {
            return .success(())
        }
    }
}
