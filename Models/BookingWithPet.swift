//
//  BookingWithPet.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 1/5/26.
//

import Foundation

struct BookingWithPet: Identifiable, Hashable {
    let booking: Booking
    let pet: Pet

    var id: UUID { booking.id }
}
