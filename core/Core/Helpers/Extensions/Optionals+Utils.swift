//
//  Optionals+Utils.swift
//  Core
//
//  Created by Atilla Özder on 4.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation

extension Optional where Wrapped == String {
    var stringValue: String {
        return self ?? ""
    }
}
