//
//  Layout.swift
//  PicVidExplore
//
//  Created by Nguyễn Hải Âu   on 23/12/2023.
//

import SwiftUI

/// WaterfallGrid layout
struct Layout<Content: View, T: Identifiable>: View where T: Hashable {
    var content: (Int, T) -> Content
    var items: [T]
    var columns: Int
    var spacing: CGFloat
    
    init(columns: Int, items: [T], spacing: CGFloat, @ViewBuilder content: @escaping (Int, T) -> Content) {
        self.items = items
        self.content = content
        self.columns = columns
        self.spacing = spacing
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            HStack(alignment: .top, spacing: spacing) {
                ForEach(setUpItems(), id: \.self) { columnData in
                    VStack(spacing: spacing) {
                        ForEach(columnData) { item in
                            content(item.id as! Int, item)
                        }
                    }
                }
            }
            .padding(.vertical)
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
