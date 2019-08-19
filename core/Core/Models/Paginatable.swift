//
//  Paginatable.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation

protocol Paginatable: Codable {
    associatedtype Item: PageItem
    var count: Int? { get }
    var next: String? { get }
    var previous: String? { get }
    var items: [Item] { get }
}

protocol PageItem: Codable {}
