//
//  String+Utils.swift
//  Core
//
//  Created by Atilla Özder on 4.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation

extension String {
    
    func asURL() -> URL? {
        return URL(string: self)
    }
    
    /// Returns a localized String
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
