//
//  SupabaseAuthResponse.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 1/3/26.
//

import Foundation

struct SupabaseAuthResponse: Codable {
    let accessToken: String?
    let user: SupabaseUser?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case user
    }
}
