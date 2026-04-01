//
//  Config.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 12/31/25.
//

import Foundation

enum Config {
    // ✅ Replace with your Supabase values
    static let supabaseURL = URL(string: "https://aorlqzdwjibdkojklaho.supabase.co")!
    static let supabaseAnonKey = "sb_publishable_i6ejDaIlYdmaN7hHlqGSoA_t3RX_aK_"

    // Optional: your Stripe backend (already have)
    static let stripeBackendBaseURL = URL(string: "https://YOUR-RENDER-URL.onrender.com")!
}
