//
//  HomeView.swift
//  PicVidExplore
//
//  Created by Nguyễn Hải Âu   on 23/12/2023.
//

import SwiftUI

//struct HomeView: View {
//    private let itemWidth = (AppConstants.screenWidth - 30) / 2
//    @State private var items: [Model] = Model.allItem
//    @State private var itemHeightCaches: [Int: CGFloat] = [:]
//    @ObservedObject private var videoStateManager = VideoStateManager()
//    
//    var body: some View {
//        NavigationStack {
//            Layout(columns: 2, items: items, spacing: 10) { index, item in
//                NavigationLink(destination: DetailView(item: item)) {
//                    switch item.getType() {
//                    case .image:
//                        ImageView(image: item)
//                            .background(
//                                GeometryReader { geometry in
//                                    Color.clear
//                                        .onAppear {
//                                            let aspectRatio = item.width / item.height
//                                            let calculatedHeight = itemWidth / aspectRatio
//                                            itemHeightCaches[item.id] = calculatedHeight
//                                        }
//                                }
//                            )
//                            .frame(height: itemHeightCaches[item.id])
//                    case .video:
//                        VideoPlayerView(video: item, videoCacheManager: VideoCacheManager.shared, videoStateManager: videoStateManager)
//                            .background(
//                                GeometryReader { geometry in
//                                    Color.clear.preference(key: ViewOffsetKey.self, value: -geometry.frame(in: .named("scroll")).origin.y)
//                                        .onAppear {
//                                            let aspectRatio = item.width / item.height
//                                            let calculatedHeight = itemWidth / aspectRatio
//                                            itemHeightCaches[item.id] = calculatedHeight
//                                        }
//                                }
//                            )
//                            .frame(height: itemHeightCaches[item.id])
//                            .onPreferenceChange(ViewOffsetKey.self) { offset in
//                                let visibleScreen = AppConstants.screenHeight - AppConstants.navigationBarHeight - AppConstants.tabBarHeight
//                                let shouldPlay = offset >= -(visibleScreen - (itemHeightCaches[item.id] ?? 0) * 1 / 3) && offset <= (itemHeightCaches[item.id] ?? 0) * 2 / 3
//                                videoStateManager.setPlaying(shouldPlay, for: item)
//                            }
//                    case .unknown:
//                        EmptyView()
//                    }
//                }
//                .buttonStyle(StaticButtonStyle())
//            }
//            .coordinateSpace(name: "scroll")
//            .padding(.horizontal, 10)
//            .navigationTitle(Tab.all.title)
//            .navigationBarTitleDisplayMode(.inline)
//        }
//    }
//}


struct HomeView: View {
    private let itemWidth = (AppConstants.screenWidth - 30) / 2
    @State private var items: [Model] = Model.allItem
    @State private var itemHeightCaches: [Int: CGFloat] = [:]
    @ObservedObject private var videoStateManager = VideoStateManager()
    var coordinator: UICoordinator = .init()
    
    var body: some View {
        Layout(columns: 2, items: items, spacing: 10, coordinator: coordinator) { index, item in
            switch item.getType() {
            case .image:
                GeometryReader {
                    let frame = $0.frame(in: .global)
                    ImageView(image: item)
                        .background(
                            Color.clear
                                .onAppear {
                                    let aspectRatio = item.width / item.height
                                    let calculatedHeight = itemWidth / aspectRatio
                                    itemHeightCaches[item.id] = calculatedHeight
                                }
                        )
                        .frame(width: frame.width, height: frame.height)
                        .onTapGesture {
                            coordinator.toogleView(show: true, frame: frame, model: item)
                        }
                }
                .frame(height: itemHeightCaches[item.id])
            case .video:
                GeometryReader { geometry in
                    let frame = geometry.frame(in: .global)
                    VideoPlayerView(video: item, videoCacheManager: VideoCacheManager.shared, videoStateManager: videoStateManager)
                        .background(
                            Color.clear.preference(key: ViewOffsetKey.self, value: -geometry.frame(in: .named("scroll")).origin.y)
                                .onAppear {
                                    let aspectRatio = item.width / item.height
                                    let calculatedHeight = itemWidth / aspectRatio
                                    itemHeightCaches[item.id] = calculatedHeight
                                }
                        )
                        .frame(width: frame.width, height: frame.height)
                        .onPreferenceChange(ViewOffsetKey.self) { offset in
                            let visibleScreen = AppConstants.screenHeight - AppConstants.navigationBarHeight - AppConstants.tabBarHeight
                            let shouldPlay = offset >= -(visibleScreen - (itemHeightCaches[item.id] ?? 0) * 1 / 3) && offset <= (itemHeightCaches[item.id] ?? 0) * 2 / 3
                            videoStateManager.setPlaying(shouldPlay, for: item)
                        }
                }
                .frame(height: itemHeightCaches[item.id])
            case .unknown:
                EmptyView()
            }
        }
        .coordinateSpace(name: "scroll")
        .navigationTitle(Tab.all.title)
        .navigationBarTitleDisplayMode(.inline)
        .opacity(coordinator.hideRootView ? 0 : 1)
        .overlay {
            TestDetailView()
                .environment(coordinator)
        }
    }
}

struct TestDetailView: View {
    @Environment(UICoordinator.self) private var coordinator
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            let animateView = coordinator.animateView
            let hideView = coordinator.hideRootView
            let hideLayer = coordinator.hideLayer
            let rect = coordinator.rect
            
            let anchorX = (coordinator.rect.minX / size.width) > 0.5 ? 1.0 : 0.0
            let scale = size.width / coordinator.rect.width
            
            /// 15 -> Horizontal Padding
            let offsetX = animateView ? (anchorX > 0.5 ? 15 : 15) * scale : 0
            let offsetY = animateView ? (-coordinator.rect.minY) * scale : 0
            
            if let image = coordinator.animationLayer, let item = coordinator.selectedItem {
                if !hideLayer {
                    Image(uiImage: image)
                        .scaleEffect(animateView ? scale : 1, anchor: .init(x: anchorX, y: 0))
                        .offset(x: offsetX, y: offsetY)
                        .opacity(animateView ? 0 : 1)
                        .transition(.identity)
                }
                
                ZStack(alignment: .top) {
                    /// Hero Kinda View
                    ImageView(image: item)
                        .allowsHitTesting(false)
                        .frame(
                            width: animateView ? size.width : rect.width,
                            height: animateView ? rect.height * scale : rect.height
                        )
                        .clipShape(.rect(cornerRadius: animateView ? 0 : 16))
//                        .overlay {
//                            makeBackView(item)
//                        }
                        .overlay {
                            Button(action: {
                                coordinator.toogleView(show: false, frame: .zero, model: item)
                            }, label: {
                                Color.clear
                                    .frame(
                                        width: animateView ? size.width : rect.width,
                                        height: animateView ? rect.height * scale : rect.height
                                    )
                            })
                        }
                        .offset(x: animateView ? 0 : rect.minX, y: animateView ? 0 : rect.minY)
                }
            }
        }
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private func makeBackView(_ model: Model) -> some View {
        HStack {
            Button(action: {
                coordinator.toogleView(show: false, frame: .zero, model: model)
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
}

struct ImageView: View {
    let image: Model
    var body: some View {
        let components = image.name.components(separatedBy: ".")
        if let imageUrl = Bundle.main.url(forResource: components.first, withExtension: components.last),
           let imageData = try? Data(contentsOf: imageUrl),
           let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .frame(minWidth: 0, maxWidth: .infinity)
                .clipShape(.rect(cornerRadius: 16))
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
