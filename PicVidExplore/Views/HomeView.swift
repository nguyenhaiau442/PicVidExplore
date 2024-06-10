//
//  HomeView.swift
//  PicVidExplore
//
//  Created by Nguyễn Hải Âu   on 23/12/2023.
//

import SwiftUI

struct HomeView: View {
    private let itemWidth = (AppConstants.screenWidth - 30) / 2
    @State private var items: [Model] = Model.allItem
    @State private var itemHeightCaches: [Int: CGFloat] = [:]
    @ObservedObject private var videoStateManager = VideoStateManager()
    var coordinator: UICoordinator = .init()
    
    var body: some View {
        NavigationStack {
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
            .scrollDisabled(coordinator.hideRootView)
            .allowsTightening(!coordinator.hideRootView)
            .overlay {
                TestDetailView()
                    .environment(coordinator)
                    .allowsTightening(!coordinator.hideLayer)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct TestDetailView: View {
    @Environment(UICoordinator.self) private var coordinator
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationStack {
            GeometryReader {
                let size = $0.size
                let animateView = coordinator.animateView
                let hideLayer = coordinator.hideLayer
                let rect = coordinator.rect
                
                let anchorX = (coordinator.rect.minX / size.width) > 0.5 ? 1.0 : 0.0
                let scale = size.width / coordinator.rect.width
                
                /// 15 -> Horizontal Padding
                let offsetX = animateView ? (anchorX > 0.5 ? 15 : -15) * scale : 0
                let offsetY = animateView ? (-coordinator.rect.minY) * scale : 0
                
                let detailHeight: CGFloat = (rect.height * scale)
                let scrollContentHeight: CGFloat = (size.height - detailHeight)
                
                if let image = coordinator.animationLayer, let item = coordinator.selectedItem {
                    if !hideLayer {
                        Image(uiImage: image)
                            .scaleEffect(animateView ? scale : 1, anchor: .init(x: anchorX, y: 0))
                            .offset(x: offsetX, y: offsetY)
                            .offset(y: animateView ? -coordinator.headerOffset : 0)
                            .opacity(animateView ? 0 : 1)
                            .transition(.identity)
                    }
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        scrollContent()
                            .safeAreaInset(edge: .top, spacing: 10) {
                                Rectangle()
                                    .fill(.clear)
                                    .frame(height: detailHeight)
                                    .offsetY { offset in
                                        coordinator.headerOffset = max(min(-offset, detailHeight), 0)
                                    }
                            }
                    }
                    .scrollDisabled(!hideLayer)
                    .contentMargins(.top, detailHeight, for: .scrollIndicators)
                    .background {
                        Rectangle()
                            .fill(.background)
                            .padding(.top, scrollContentHeight)
                    }
                    .animation(.easeInOut(duration: 0.3).speed(1.5)) {
                        $0
                            .offset(y: animateView ? 0 : scrollContentHeight)
                            .opacity(animateView ? 1 : 0)
                    }
                    .onAppear {
                        UIScrollView.appearance().bounces = false
                    }
                    .onDisappear {
                        UIScrollView.appearance().bounces = true
                    }
                    
                    /// Hero Kinda View
                    ImageView(image: item)
                        .allowsHitTesting(false)
                        .frame(
                            width: animateView ? size.width : rect.width,
                            height: animateView ? rect.height * scale : rect.height
                        )
                        .overlay(alignment: .top, content: {
                            makeBackView(item)
                                .offset(y: coordinator.headerOffset)
                                .padding(.top, safeArea.top)
                        })
                        .offset(x: animateView ? 0 : rect.minX, y: animateView ? 0 : rect.minY)
                        .offset(y: animateView ? -coordinator.headerOffset : 0)
                }
            }
            .ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    private func makeBackView(_ model: Model) -> some View {
        HStack {
            Button(action: {
                coordinator.toogleView(show: false, frame: .zero, model: model)
            }, label: {
                Image(systemName: "chevron.backward.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(Color.white)
                    .padding(10)
                    .contentShape(.rect)
            })
            Spacer(minLength: 0)
        }
        .animation(.easeInOut(duration: 0.3)) {
            $0
                .opacity(coordinator.hideLayer ? 1 : 0)
        }
    }
    
    @ViewBuilder
    private func scrollContent() -> some View {
        VStack(spacing: 0) {
            makeProfileView()
            makeActionView()
            Divider()
            Spacer(minLength: 0)
        }
        .frame(height: 1000)
    }
    
    @ViewBuilder
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
    
    @ViewBuilder
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
