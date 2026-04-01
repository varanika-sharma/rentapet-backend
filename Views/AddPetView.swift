//
//  AddPetView.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 12/31/25.
//

import SwiftUI

struct AddPetView: View {
    @EnvironmentObject private var authStore: AuthStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var type = "Dog"
    @State private var age = 1
    @State private var pricePerDay = 25.0
    @State private var description = ""

    @State private var errorText: String?
    @State private var isSaving = false

    let onDone: () -> Void

    var body: some View {
        Form {
            Section("Basics") {
                TextField("Name", text: $name)

                Picker("Type", selection: $type) {
                    Text("Dog").tag("Dog")
                    Text("Cat").tag("Cat")
                }

                Stepper("Age: \(age)", value: $age, in: 0...30)

                HStack {
                    Text("Price/day")
                    Spacer()
                    TextField("", value: $pricePerDay, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
            }

            Section("About") {
                TextField("Description", text: $description, axis: .vertical)
                    .lineLimit(4...8)
            }

            if let errorText {
                Text(errorText).foregroundColor(.red)
            }
        }
        .navigationTitle("Add Pet")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(isSaving ? "Saving…" : "Save") {
                    Task { await save() }
                }
                .disabled(isSaving || name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    private func save() async {
        guard let token = authStore.accessToken,
              let ownerId = authStore.userId else {
            errorText = "Please log in again."
            return
        }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            errorText = "Name is required."
            return
        }

        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalDescription = trimmedDescription.isEmpty ? "Friendly and well-trained." : trimmedDescription

        isSaving = true
        errorText = nil

        do {
            try await PetsAPI.createPet(
                accessToken: token,
                ownerId: ownerId.uuidString,   // ✅ FIX HERE
                name: trimmedName,
                type: type,
                age: age,
                pricePerDay: pricePerDay,
                description: finalDescription
            )

            isSaving = false
            onDone()
            dismiss()
        } catch {
            errorText = error.localizedDescription
            isSaving = false
        }
    }
}
