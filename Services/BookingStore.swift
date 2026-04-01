//
//  BookingStore.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 12/24/25.
//
import SwiftUI
import Foundation
import Combine


final class BookingStore: ObservableObject {
    @Published private(set) var bookings: [Booking] = []

    private let key = "saved_bookings_v2"

    init() {
        load()
    }

    func add(_ booking: Booking) {
        bookings.insert(booking, at: 0)
        save()
    }
    
    func remove(at offsets: IndexSet) {
        bookings.remove(atOffsets: offsets)
        save()
    }

    func clearAll() {
        bookings.removeAll()
        save()
    }

    // MARK: - Persistence

    private func save() {
        do {
            let data = try JSONEncoder().encode(bookings)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("❌ Failed to save bookings:", error)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key) else { return }
        do {
            bookings = try SupabaseJSON.decoder().decode([Booking].self, from: data)
        } catch {
            print("❌ Failed to load bookings:", error)
        }
    }
}
