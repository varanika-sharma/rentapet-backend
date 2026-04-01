//
//  AppState.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 12/24/25.
//

import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var selectedTabIndex: Int = 0
    @Published var homePath = NavigationPath()
    @Published var bookingsPath = NavigationPath()
}
