//
//  DetailView.swift
//  PicVidExplore
//
//  Created by Nguyễn Hải Âu   on 23/12/2023.
//

import SwiftUI

struct DetailView: View {
    var item: Model
    @Environment(\.dismiss) private var popView
    private let itemWidth = (AppConstants.screenWidth - 30) / 2
    @State private var items: [Model] = Model.allItem
    @State private var itemHeightCaches: [Int: CGFloat] = [:]
    @ObservedObject private var videoStateManager = VideoStateManager()
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    let components = item.name.components(separatedBy: ".")
                    if item.getType() == .image,
                       let imageUrl = Bundle.main.url(forResource: components.first,
                                                      withExtension: components.last),
                       let imageData = try? Data(contentsOf: imageUrl),
                       let uiImage = UIImage(data: imageData) {
                        makeImageView(uiImage: uiImage)
                        makeProfileView()
                        makeActionView()
                        Divider()
                    }
                }
            }
            makeBackView()
        }
        .navigationBarBackButtonHidden()
    }
    
    private func makeBackView() -> some View {
        HStack {
            Button(action: {
                self.popView()
            }, label: {
                Image(systemName: "chevron.backward.circle.fill")
                    .renderingMode(.template)
                    .resizable()
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
            })
            .padding(.leading, 16)
            Spacer()
        }
        .frame(height: 50)
    }
    
    private func makeImageView(uiImage: UIImage) -> some View {
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
    
    private func makeProfileView() -> some View {
        HStack {
            if let imageUrl = Bundle.main.url(forResource: "image37",
                                              withExtension: "jpg"),
               let imageData = try? Data(contentsOf: imageUrl),
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .padding(.leading, 16)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Hải Âu Nguyễn")
                    .font(.system(size: 18, weight: .bold))
                Text("14k followers")
                    .font(.system(size: 12))
            }
            
            Spacer()
            
            Button(action: {
                print(123)
            }, label: {
                Text("Follow")
                    .foregroundStyle(colorScheme == .dark ? .black : .white)
                    .font(.system(size: 16, weight: .semibold))
                    .padding([.leading, .trailing], 24)
            })
            .frame(height: 50)
            .background(colorScheme == .dark ? .white : .black)
            .clipShape(
                RoundedRectangle(cornerRadius: 40)
            )
            .padding(.trailing, 16)
        }
        .frame(width: AppConstants.screenWidth, height: 80)
    }
    
    private func makeActionView() -> some View {
        HStack {
            Button(action: {
                
            }, label: {
                Image(systemName: "heart")
                    .resizable()
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    .frame(width: 22, height: 22)
            })
            .padding(.leading, 16)
            
            Spacer()
            
            HStack(spacing: 16) {
                Button(action: {
                    print(123)
                }, label: {
                    Text("Make it")
                        .foregroundStyle(colorScheme == .dark ? .black : .white)
                        .font(.system(size: 16, weight: .semibold))
                        .padding([.leading, .trailing], 24)
                })
                .frame(height: 50)
                .background(colorScheme == .dark ? .white : .black)
                .clipShape(
                    RoundedRectangle(cornerRadius: 40)
                )
                
                Button(action: {
                    print(123)
                }, label: {
                    Text("Save")
                        .foregroundStyle(.white)
                        .font(.system(size: 16, weight: .semibold))
                        .padding([.leading, .trailing], 24)
                })
                .frame(height: 50)
                .background(.red)
                .clipShape(
                    RoundedRectangle(cornerRadius: 40)
                )
            }
            
            Spacer()
            
            Button(action: {
                
            }, label: {
                Image(systemName: "square.and.arrow.up")
                    .resizable()
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    .frame(width: 22, height: 22)
            })
            .padding(.trailing, 16)
        }
        .frame(width: AppConstants.screenWidth, height: 80)
    }
}

#Preview {
    ContentView()
}
