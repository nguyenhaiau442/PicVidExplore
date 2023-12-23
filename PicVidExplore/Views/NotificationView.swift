//
//  NotificationView.swift
//  PicVidExplore
//
//  Created by Nguyễn Hải Âu   on 23/12/2023.
//

import SwiftUI

struct NotificationView: View {
    var body: some View {
        NavigationStack {
            Text("Notification View")
            .navigationTitle(Tab.notifications.title)
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
}

#Preview {
    NotificationView()
}
