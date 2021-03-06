//
//  PagedCategory.swift
//  Core
//
//  Created by Atilla Özder on 4.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation

struct PagedCategory: Paginatable {
    typealias PageItem = Category
    
    let count: Int?
    let next: String?
    let previous: String?
    var items: [Category]
    
    private enum CodingKeys: String, CodingKey {
        case count
        case next
        case previous
        case items = "results"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        count = try container.decodeIfPresent(Int.self, forKey: .count)
        next = try container.decodeIfPresent(String.self, forKey: .next)
        previous = try container.decodeIfPresent(String.self, forKey: .previous)
        items = try container.decode([Category].self, forKey: .items)
    }
}
