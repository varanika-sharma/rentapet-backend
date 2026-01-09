//
//  ImageCarouselView.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 12/24/25.
//

import SwiftUI

struct ImageCarouselView: View {
    let imageNames: [String]

    @State private var showViewer = false
    @State private var currentIndex = 0

    private var uniqueNames: [String] {
        Array(NSOrderedSet(array: imageNames)) as? [String] ?? imageNames
    }

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(uniqueNames.enumerated()), id: \.offset) { i, name in
                Image(name)
                    .resizable()
                    .scaledToFill()
                    .tag(i)
                    .clipped()
                    .onTapGesture {
                        showViewer = true
                    }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: uniqueNames.count > 1 ? .automatic : .never))
        .frame(height: 240)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(radius: 8)
        .fullScreenCover(isPresented: $showViewer) {
            PhotoViewerView(imageNames: uniqueNames, startIndex: currentIndex)
        }
    }
}
