//
//  ImageCacheManager.swift
//  PicVidExplore
//
//  Created by Nguyễn Hải Âu   on 23/12/2023.
//

import SwiftUI

class ImageCacheManager {
    static let shared = ImageCacheManager()
    private var cache = NSCache<NSString, UIImage>()
    
    func getImage(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func setImage(image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}
