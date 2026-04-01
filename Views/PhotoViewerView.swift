//
//  PhotoViewerView.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 12/24/25.
//

import SwiftUI

struct PhotoViewerView: View {
    let imageNames: [String]
    @Environment(\.dismiss) private var dismiss
    @State private var index: Int

    init(imageNames: [String], startIndex: Int = 0) {
        self.imageNames = imageNames
        _index = State(initialValue: startIndex)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            TabView(selection: $index) {
                ForEach(Array(imageNames.enumerated()), id: \.offset) { i, name in
                    Image(name)
                        .resizable()
                        .scaledToFit()
                        .tag(i)
                        .padding()
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.9))
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}
