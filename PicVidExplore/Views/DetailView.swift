//
//  DetailView.swift
//  PicVidExplore
//
//  Created by Nguyễn Hải Âu   on 23/12/2023.
//

import SwiftUI

struct DetailView: View {
    var item: Model
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 10) {
                let components = item.name.components(separatedBy: ".")
                if item.getType() == .image,
                   let imageUrl = Bundle.main.url(forResource: components.first, withExtension: components.last),
                   let imageData = try? Data(contentsOf: imageUrl),
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .clipShape(
                            .rect(
                                topLeadingRadius: 40,
                                bottomLeadingRadius: 0,
                                bottomTrailingRadius: 0,
                                topTrailingRadius: 40
                            )
                        )
                }
                if item.getType() == .video {
                    
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
