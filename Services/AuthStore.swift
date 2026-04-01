//
//  AuthStore.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 12/31/25.
//

import Foundation
import Combine

@MainActor
final class AuthStore: ObservableObject {
    @Published var accessToken: String? = nil
    @Published var userId: UUID? = nil

    var isAuthenticated: Bool {
        guard let token = accessToken, !token.isEmpty, userId != nil else { return false }
        return token.split(separator: ".").count == 3
    }

    func signUp(email: String, password: String) async throws {
        let session = try await SupabaseAuthAPI.signUp(email: email, password: password)
        apply(session: session)
    }

    func signIn(email: String, password: String) async throws {
        let session = try await SupabaseAuthAPI.signIn(email: email, password: password)
        apply(session: session)
    }

    func signOut() {
        accessToken = nil
        userId = nil
    }

    private func apply(session: SupabaseSession) {
        // ✅ REAL JWT
        self.accessToken = session.accessToken

        // ✅ userId as UUID (pets/booking use this)
        if let uuid = UUID(uuidString: session.user.id) {
            self.userId = uuid
        } else {
            self.userId = nil
        }

        // Helpful debug
        print("✅ token parts =", session.accessToken.split(separator: ".").count) // should be 3
        print("✅ user id =", session.user.id)
    }
}
