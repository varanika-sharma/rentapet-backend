//
//  PetCardView.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 12/23/25.
//
import SwiftUI

struct PetCardView: View {
    let pet: Pet

    private var localImageName: String {
        pet.imageName ?? "pawprint.fill"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            if let imageName = pet.imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 160)
                    .clipped()
                    .cornerRadius(16)
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 160)
                    .overlay(
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    )
            }

            Text(pet.name)
                .font(.headline)

            Text("\(pet.type) • \(pet.age) years old")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack {
                Text("$\(pet.pricePerDay, specifier: "%.0f") / day")
                    .font(.headline)
                    .foregroundColor(.green)

                Spacer()

                Text("Book")
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(radius: 5)
        )
    }
}
