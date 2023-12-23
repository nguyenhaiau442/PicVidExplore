//
//  Tab.swift
//  PicVidExplore
//
//  Created by Nguyễn Hải Âu   on 23/12/2023.
//

import SwiftUI

/// Tab's
enum Tab: String, CaseIterable {
    case all = "photo.stack.fill"
    case chat = "bubble.left.and.text.bubble.right.fill"
    case search = "magnifyingglass"
    case notifications = "bell.and.waves.left.and.right.fill"
    case profile = "person.crop.rectangle.stack.fill"
    
    var title: String {
        switch self {
        case .all:
            return "All"
        case .chat:
            return "Chat"
        case .search:
            return "Search"
        case .notifications:
            return "Notifications"
        case .profile:
            return "Profile"
        }
    }
}

/// Animated SF Tab Model
struct AnimatedTab: Identifiable {
    var id: UUID = .init()
    var tab: Tab
    var isAnimating: Bool?
}
