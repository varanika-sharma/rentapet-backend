//
//  Rent_a_PetApp.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 12/23/25.
//
import SwiftUI

@main
struct Rent_a_PetApp: App {
    @StateObject private var authStore = AuthStore()
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView() // ✅ use your existing root gate
                .environmentObject(authStore)
                .environmentObject(appState)
        }
    }
}
