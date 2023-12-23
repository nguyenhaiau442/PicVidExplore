//
//  VideoStateManager.swift
//  PicVidExplore
//
//  Created by Nguyễn Hải Âu   on 23/12/2023.
//

import SwiftUI

class VideoStateManager: ObservableObject {
    @Published var isPlayingMap: [Model: Bool] = [:]
    
    func isPlaying(for video: Model) -> Bool {
        return isPlayingMap[video, default: false]
    }
    
    func setPlaying(_ isPlaying: Bool, for video: Model) {
        guard isPlayingMap[video] != isPlaying else {
            return
        }
        isPlayingMap[video] = isPlaying
        objectWillChange.send()
    }
}
