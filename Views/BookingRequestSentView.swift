//
//  BookingRequestSentView.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 12/31/25.
//

import SwiftUI

struct BookingRequestSentView: View {
    let booking: Booking
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "paperplane.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.accent)

            Text("Request Sent")
                .font(.title).bold()

            Text("Status: Pending")
                .foregroundColor(.secondary)

            Button("Done") {
                dismiss()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppTheme.primary)
            .foregroundColor(.white)
            .cornerRadius(14)

            Spacer()
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }
}
