//
//  Identifiable.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation

protocol Identifiable {
    var identifier: String { get }
    func isEqual(_ object: Identifiable) -> Bool
    func set(_ object: Identifiable)
}

extension Identifiable {
    func isEqual(_ object: Identifiable) -> Bool {
        return self.identifier == object.identifier
    }
    
    func set(_ object: Identifiable) {
        return
    }
}
