//
//  ProfileView.swift
//  PicVidExplore
//
//  Created by Nguyễn Hải Âu   on 23/12/2023.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            Text("Profile View")
            .navigationTitle(Tab.profile.title)
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
}

#Preview {
    ProfileView()
}
