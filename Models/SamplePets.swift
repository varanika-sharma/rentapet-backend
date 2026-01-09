//
//  SamplePets.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 12/23/25.
//
import Foundation

let samplePets: [Pet] = [
    Pet(
        id: UUID(),
        ownerId: UUID(),
        name: "Bella",
        type: "Dog",
        age: 6,
        pricePerDay: 35,
        description: "Friendly, well-trained, and perfect for pet sitting.",
        imageURLs: [],
        imageName: "dog_bella"
    ),
    Pet(
        id: UUID(),
        ownerId: UUID(),
        name: "Milo",
        type: "Cat",
        age: 10,
        pricePerDay: 20,
        description: "Calm, cuddly, and loves naps.",
        imageURLs: [],
        imageName: "cat_milo"
    ),
    Pet(
        id: UUID(),
        ownerId: UUID(),
        name: "Ronald",
        type: "Dog",
        age: 2,
        pricePerDay: 40,
        description: "Playful energy and great on walks.",
        imageURLs: [],
        imageName: "dog_ronald"
    ),
    Pet(
        id: UUID(),
        ownerId: UUID(),
        name: "Quinn",
        type: "Cat",
        age: 8,
        pricePerDay: 20,
        description: "Sweet, quiet, and very affectionate.",
        imageURLs: [],
        imageName: "cat_quinn"
    )
]
