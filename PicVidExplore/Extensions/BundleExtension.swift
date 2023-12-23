//
//  BundleExtension.swift
//  PicVidExplore
//
//  Created by Nguyễn Hải Âu   on 23/12/2023.
//

import SwiftUI

extension Bundle {
    func decode<T: Decodable>(file: String) -> T {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Could not find \(file) in the project!!!")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Could not load \(file) in the project!!!")
        }
        
        let decoder = JSONDecoder()
        
        guard let data = try? decoder.decode(T.self, from: data) else {
            fatalError("Could not decode \(file) in the project!!!")
        }
        
        return data
    }
}
