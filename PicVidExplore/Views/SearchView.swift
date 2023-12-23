//
//  SearchView.swift
//  PicVidExplore
//
//  Created by Nguyễn Hải Âu   on 23/12/2023.
//

import SwiftUI

struct SearchView: View {
    var body: some View {
        NavigationStack {
            Text("Search View")
            .navigationTitle(Tab.search.title)
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
}

#Preview {
    SearchView()
}
