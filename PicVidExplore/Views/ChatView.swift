//
//  ChatView.swift
//  PicVidExplore
//
//  Created by Nguyễn Hải Âu   on 23/12/2023.
//

import SwiftUI

struct ChatView: View {
    var body: some View {
        NavigationStack {
            Text("Chat View")
            .navigationTitle(Tab.chat.title)
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
}

#Preview {
    ChatView()
}
