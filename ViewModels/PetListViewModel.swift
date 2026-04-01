//
//  PetListViewModel.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 12/23/25.
//
import Foundation
import Combine


@MainActor
final class PetListViewModel: ObservableObject {
    @Published var pets: [Pet] = []
    @Published var isLoading = false
    @Published var errorText: String?

    func loadPets(accessToken: String?) async {
        isLoading = true
        errorText = nil

        do {
            guard let token = accessToken else {
                errorText = "Please log in to view pets."
                isLoading = false
                return
            }

            let result = try await PetsAPI.fetchPets(accessToken: token)
            pets = result
        } catch {
            errorText = error.localizedDescription
        }

        isLoading = false
    }
}
