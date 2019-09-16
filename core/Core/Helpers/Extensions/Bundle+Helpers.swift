//
//  Bundle+Helpers.swift
//  Core
//
//  Created by Atilla Özder on 16.09.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation

extension Bundle {
    var displayName: String {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "HD Wallpapers"
    }
}
