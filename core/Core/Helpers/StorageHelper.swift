//
//  StorageHelper.swift
//  Core
//
//  Created by Atilla Özder on 25.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation

class StorageHelper {
    
    private let defaults = UserDefaults.standard
    private static let instance = StorageHelper()
    
    private init() {}
    
    static func shared() -> StorageHelper {
        return instance
    }
    
    func value(for image: Image) -> Bool {
        return defaults.bool(forKey: "\(image.id)")
    }
    
    func favorites() -> [Image] {
        if let images = defaults.object(forKey: "favorite_preference") as? Data {
            let decoder = JSONDecoder()
            if let loadedImages = try? decoder.decode([Image].self, from: images) {
                return loadedImages
            }
        }
        return []
    }
    
    private func saveImages(_ images: [Image]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(images) {
            defaults.set(encoded, forKey: "favorite_preference")
        }
    }
    
    func toggleFavorite(for image: Image) {
        let newValue = !self.value(for: image)
        defaults.set(newValue, forKey: "\(image.id)")
        newValue ? addFavorite(image) : removeFavorite(image)
    }
    
    private func addFavorite(_ image: Image) {
        var arr = favorites()
        arr.append(image)
        saveImages(arr)
    }
    
    private func removeFavorite(_ image: Image) {
        var arr = favorites()
        arr.removeAll(where: { $0.id == image.id })
        saveImages(arr)
    }
}
