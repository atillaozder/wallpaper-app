//
//  Image.swift
//  Core
//
//  Created by Atilla Özder on 4.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation

struct Image: PageItem {
    var id: Int
    var image: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case image
    }
    
    init() {
        self.id = 0
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
    }
}
