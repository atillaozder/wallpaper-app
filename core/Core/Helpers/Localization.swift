//
//  Localization.swift
//  Core
//
//  Created by Atilla Özder on 10.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation

struct Localization {
    static var setAsWallpaper: String {
        return "set_as_wallpaper".localized.capitalized(with: .current)
    }
    
    static var share: String {
        return "share".localized.capitalized(with: .current)
    }
    
    static var save: String {
        return "save".localized.capitalized(with: .current)
    }
    
    static var saved: String {
        return "saved".localized.capitalized(with: .current)
    }
    
    static var recent: String {
        return "recent".localized.capitalized(with: .current)
    }
    
    static var category: String {
        return "category".localized.capitalized(with: .current)
    }
    
    static var favorites: String {
        return "favorites".localized.capitalized(with: .current)
    }
    
    static var photoPermissionTitle: String {
        return "photoPermissionTitle".localized
    }
    
    static var photoPermissionMessage: String {
        return "photoPermissionMessage".localized
    }
    
    static var cancel: String {
        return "cancel".localized.capitalized(with: .current)
    }
    
    static var openSettingsTitle: String {
        return "openSettingsTitle".localized
    }
}
