//
//  Layout.swift
//  PicVidExplore
//
//  Created by Nguyễn Hải Âu   on 23/12/2023.
//

import SwiftUI

struct Layout<Content: View, T: Identifiable>: View where T: Hashable {
    var content: (Int, T) -> Content
    var items: [T]
    var columns: Int
    var spacing: CGFloat
    var coordinator: UICoordinator
    
    init(columns: Int, items: [T], spacing: CGFloat, coordinator: UICoordinator, @ViewBuilder content: @escaping (Int, T) -> Content) {
        self.items = items
        self.content = content
        self.columns = columns
        self.spacing = spacing
        self.coordinator = coordinator
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            HStack(alignment: .top, spacing: spacing) {
                ForEach(setUpItems(), id: \.self) { columnData in
                    VStack(spacing: spacing) {
                        ForEach(Array(columnData.enumerated()), id: \.element.id) { index, item in
                            content(index, item)
                        }
                    }
                }
            }
            .background(ScrollViewExtractor(result: { scrollView in
                coordinator.scrollView = scrollView
            }))
            .padding(.horizontal, 15)
        }
    }
    
    private func setUpItems() -> [[T]] {
        var gridArray: [[T]] = Array(repeating: [], count: columns)
        var currentIndex: Int = 0
        for item in items {
            gridArray[currentIndex].append(item)
            currentIndex = (currentIndex + 1) % columns
        }
        return gridArray
    }
}
