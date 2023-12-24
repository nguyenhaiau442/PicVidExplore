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
    let width: Double
    let height: Double
    let duration: Double?
    
    static let allItem: [Model] = Bundle.main.decode(file: "Data.json")
    
    func getType() -> ModelType {
        let components = name.components(separatedBy: ".")
        switch components.last {
        case "jpg":
            return .image
        case "mp4":
            return .video
        default:
            return .unknown
        }
    }
}
