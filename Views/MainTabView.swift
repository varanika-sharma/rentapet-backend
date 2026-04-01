//
//  MainTabView.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 12/24/25.
//
import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        TabView(selection: $appState.selectedTabIndex) {

            // Home tab owns its NavigationStack
            NavigationStack(path: $appState.homePath) {
                HomeView()
            }
            .tabItem { Label("Home", systemImage: "house.fill") }
            .tag(0)

            // Bookings tab owns its NavigationStack
            NavigationStack(path: $appState.bookingsPath) {
                BookingsView()
            }
            .tabItem { Label("Bookings", systemImage: "calendar") }
            .tag(1)
        }
    }
}
