//
//  VideoCacheManager.swift
//  PicVidExplore
//
//  Created by Nguyễn Hải Âu   on 23/12/2023.
//

import SwiftUI
import AVFoundation

class VideoCacheManager {
    static let shared = VideoCacheManager()
    private var cache = NSCache<NSURL, AVAsset>()
    
    func getVideoAsset(for videoURL: URL) async throws -> AVAsset {
        if let cachedAsset = cache.object(forKey: videoURL as NSURL) {
            return cachedAsset
        } else {
            let asset = try await loadVideoAsset(from: videoURL)
            cache.setObject(asset, forKey: videoURL as NSURL)
            return asset
        }
    }
    
    private func loadVideoAsset(from videoURL: URL) async throws -> AVAsset {
        let asset = AVAsset(url: videoURL)
        do {
            let _ = try await asset.load(.duration, .tracks)
            return asset
        } catch {
            throw error
        }
    }
}

