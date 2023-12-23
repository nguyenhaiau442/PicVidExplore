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
                if item.getType() == .image,
                   let imageUrl = Bundle.main.url(forResource: item.name, withExtension: item.type),
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
