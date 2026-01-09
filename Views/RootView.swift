//
//  RootView.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 12/31/25.
//
import SwiftUI

struct RootView: View {
    @EnvironmentObject private var authStore: AuthStore

    var body: some View {
        Group {
            if authStore.isAuthenticated {
                MainTabView()
            } else {
                NavigationStack {
                    AuthView() // ✅ your login/signup screen
                }
            }
        }
    }
}
