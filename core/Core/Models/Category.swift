//
//  Category.swift
//  Core
//
//  Created by Atilla Özder on 4.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation

struct Category: PageItem {
    var id: Int
    var name: String
    var image: String?
    
    private enum CodingKeys: CodingKey {
        case id
        case name
        case image
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
    }
}
