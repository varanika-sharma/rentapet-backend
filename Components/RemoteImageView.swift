//
//  RemoteImageView.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 1/4/26.
//

import SwiftUI

struct RemoteImageView: View {
    let urlString: String?

    var body: some View {
        if let urlString,
           let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.gray.opacity(0.15))
                        ProgressView()
                    }

                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()

                case .failure:
                    placeholder

                @unknown default:
                    placeholder
                }
            }
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.gray.opacity(0.15))
            Image(systemName: "pawprint.fill")
                .font(.system(size: 48))
                .foregroundColor(.gray)
        }
    }
}
