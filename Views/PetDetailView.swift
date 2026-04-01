//
//  PetDetailView.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 12/23/25.
//
import SwiftUI

struct PetDetailView: View {
    let pet: Pet

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // Image
                if let imageName = pet.imageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 260)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                } else {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 260)
                        .overlay(
                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 56))
                                .foregroundColor(.gray)
                        )
                }

                Text(pet.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("\(pet.type) • \(pet.age) years old")
                    .foregroundColor(.secondary)

                Text("$\(pet.pricePerDay, specifier: "%.0f") / day")
                    .font(.title3)
                    .foregroundColor(AppTheme.accent)

                Text(pet.description)
                    .foregroundColor(.secondary)

                NavigationLink {
                    BookingView(pet: pet)
                } label: {
                    Text("Request Booking")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.primary)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
                .padding(.top, 8)
            }
            .padding()
        }
        .navigationTitle(pet.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
