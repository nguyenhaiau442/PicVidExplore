//
//  HomeView.swift
//  PicVidExplore
//
//  Created by Nguyễn Hải Âu   on 23/12/2023.
//

import SwiftUI

struct HomeView: View {
    @State private var items: [Model] = Model.allItem
    @State private var itemHeightCaches: [CGFloat] = Array(repeating: 0, count: Model.allItem.count)
    @ObservedObject private var videoStateManager = VideoStateManager()
    
    var body: some View {
        NavigationStack {
            Layout(columns: 2, items: items, spacing: 10) { index, item in
                NavigationLink(destination: DetailView(item: item)) {
                    switch item.getType() {
                    case .image:
                        ImageView(image: item)
                    case .video:
                        VideoPlayerView(video: item, videoCacheManager: VideoCacheManager.shared, videoStateManager: videoStateManager)
                            .background(
                                GeometryReader { geometry in
                                    Color.clear.preference(key: ViewOffsetKey.self, value: -geometry.frame(in: .named("scroll")).origin.y)
                                        .onAppear {
                                            let calculatedHeight = ((UIScreen.main.bounds.width - 30) / 2) / item.aspectRatio
                                            itemHeightCaches[index] = calculatedHeight
                                        }
                                }
                            )
                            .frame(height: itemHeightCaches[index])
                            .onPreferenceChange(ViewOffsetKey.self) { offset in
                                let shouldPlay = offset >= -480 && offset <= itemHeightCaches[index] * 2 / 3
                                videoStateManager.setPlaying(shouldPlay, for: item)
                            }
                            .onAppear {
                                print(index)
                            }
                    case .unknown:
                        EmptyView()
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

struct ImageView2: View {
    var body: some View {
        Rectangle()
            .foregroundColor(.blue)
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
