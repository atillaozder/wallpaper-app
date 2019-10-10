//
//  Sequence+Utils.swift
//  Core
//
//  Created by Atilla Özder on 10.10.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation

extension Array where Element: Identifiable {
    func incremented(count: Int) -> [Element] {
        var arr = self
        while arr.count <= count { arr += arr }
        return arr
    }
}
