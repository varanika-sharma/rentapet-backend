//
//  MyPetsView.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 12/31/25.
//

import SwiftUI

struct MyPetsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("My Pets")
                .font(.title2)
                .fontWeight(.bold)

            Text("Next: connect this to Supabase so users can add pets.")
                .foregroundColor(.secondary)
        }
        .padding()
        .navigationTitle("My Pets")
    }
}
