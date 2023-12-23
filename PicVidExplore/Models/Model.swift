//
//  SwiftUIView.swift
//  PicVidExplore
//
//  Created by Nguyễn Hải Âu   on 23/12/2023.
//

import SwiftUI

enum ModelType {
    case image
    case video
    case unknown
}

struct Model: Codable, Hashable, Identifiable {
    let id: Int
    let name: String
    let type: String
    let aspectRatio: Double
    
    static let allItem: [Model] = Bundle.main.decode(file: "Data.json")
    
    func getType() -> ModelType {
        switch type {
        case "jpg":
            return .image
        case "mp4":
            return .video
        default:
            return .unknown
        }
    }
}
