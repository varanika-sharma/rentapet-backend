//
//  AuthView.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 12/31/25.
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var authStore: AuthStore

    @State private var isSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var errorText: String?
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 16) {
            Text(isSignUp ? "Create Account" : "Log In")
                .font(.title)
                .fontWeight(.bold)

            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .textFieldStyle(.roundedBorder)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            if let errorText {
                Text(errorText)
                    .foregroundColor(.red)
                    .font(.subheadline)
            }

            Button {
                Task { await submit() }
            } label: {
                HStack {
                    if isLoading { ProgressView() }
                    Text(isLoading ? "Please wait…" : (isSignUp ? "Sign Up" : "Log In"))
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppTheme.primary)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(isLoading || email.isEmpty || password.isEmpty)

            Button {
                isSignUp.toggle()
                errorText = nil
            } label: {
                Text(isSignUp ? "Already have an account? Log In" : "New here? Create an account")
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
    }

    private func submit() async {
        isLoading = true
        errorText = nil

        // ✅ Trim input (THIS fixes your error)
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        // ✅ Basic validation before hitting Supabase
        guard cleanEmail.contains("@"), cleanEmail.contains(".") else {
            errorText = "Please enter a valid email address."
            isLoading = false
            return
        }

        guard cleanPassword.count >= 6 else {
            errorText = "Password must be at least 6 characters."
            isLoading = false
            return
        }

        do {
            if isSignUp {
                try await authStore.signUp(
                    email: cleanEmail,
                    password: cleanPassword
                )
            } else {
                try await authStore.signIn(
                    email: cleanEmail,
                    password: cleanPassword
                )
            }
        } catch {
            // ✅ Clean error message instead of raw JSON
            errorText = error.localizedDescription
        }

        isLoading = false
    }

}
