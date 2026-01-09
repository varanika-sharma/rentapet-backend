//
//  PaymentResult.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 12/27/25.
//

import Foundation

enum PaymentResult: Equatable {
    case idle
    case processing
    case success
    case failed(String)
}
