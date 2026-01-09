//
//  ProfileView.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 12/31/25.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Profile")
                .font(.title2)
                .fontWeight(.bold)

            Text("Next: connect this to Supabase Auth + Profiles table.")
                .foregroundColor(.secondary)
        }
        .padding()
        .navigationTitle("Profile")
    }
}
#Preview {
    ProfileView()
}