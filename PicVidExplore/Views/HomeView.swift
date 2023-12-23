//
//  HomeView.swift
//  PicVidExplore
//
//  Created by Nguyễn Hải Âu   on 23/12/2023.
//

import SwiftUI

struct HomeView: View {
    @State private var items: [Model] = Model.allItem
    @State private var videoHeight: CGFloat = 0
    @State private var videoHeightCaches: [CGFloat?] = Array(repeating: nil, count: Model.allItem.count)
    @ObservedObject private var videoStateManager = VideoStateManager()
    
    var body: some View {
        NavigationStack {
            Layout(columns: 2, items: items, spacing: 10) { index, item in
                NavigationLink(destination: DetailView(item: item)) {
                    if item.getType() == .image {
                        ImageView(image: item)
                    } else {
                        VideoPlayerView(video: item, videoCacheManager: VideoCacheManager.shared, videoStateManager: videoStateManager)
                            .frame(height: videoHeightCaches[index] ?? videoHeight)
                            .onAppear {
                                videoHeight = ((UIScreen.main.bounds.width - 30) / 2) / item.aspectRatio
                                videoHeightCaches[index] = videoHeight
                            }
                            .background(
                                GeometryReader(content: { geometry in
                                    Color.clear.preference(key: ViewOffsetKey.self, value: -geometry.frame(in: .named("scroll")).origin.y)
                                })
                            )
                            .onPreferenceChange(ViewOffsetKey.self) { offset in
                                let shouldPlay = offset >= -480 && offset <= (videoHeightCaches[index] ?? 0) * 2 / 3
                                videoStateManager.setPlaying(shouldPlay, for: item)
                            }
                    }
                }
                .buttonStyle(StaticButtonStyle())
            }
            .coordinateSpace(name: "scroll")
            .padding(.horizontal, 10)
            .navigationTitle(Tab.all.title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ImageView: View {
    let image: Model
    var body: some View {
        if let imageUrl = Bundle.main.url(forResource: image.name, withExtension: image.type),
           let imageData = try? Data(contentsOf: imageUrl),
           let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(minWidth: 0, maxWidth: .infinity)
                .cornerRadius(16)
        }
    }
}

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

struct StaticButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

#Preview {
    ContentView()
}
