//
//  FullscreenPetImageView.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 1/4/26.
//

import SwiftUI

struct FullscreenPetImageView: View {
    let title: String
    let urls: [String]
    let localFallback: String?

    @Environment(\.dismiss) private var dismiss
    @State private var index: Int = 0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            TabView(selection: $index) {
                if !urls.isEmpty {
                    ForEach(Array(urls.enumerated()), id: \.offset) { i, url in
                        RemoteImageView(urlString: url)
                            .scaledToFit()
                            .tag(i)
                            .padding()
                    }
                } else if let localFallback, !localFallback.isEmpty {
                    Image(localFallback)
                        .resizable()
                        .scaledToFit()
                        .padding()
                } else {
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }

                    Spacer()

                    Text(title)
                        .foregroundColor(.white.opacity(0.9))
                        .font(.headline)

                    Spacer()

                    // spacer to balance the X button
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding()

                Spacer()
            }
        }
    }
}
