//
//  CellImagePrefetcher.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation

protocol CellImagePrefetcher: class {
    var prefetchers: [ImagePrefetcher] { get }
    func fetchImages()
    func cancelFetching()
}

extension CellImagePrefetcher {
    func fetchImages() {
        prefetchers.forEach { $0.fetch() }
    }
    
    func cancelFetching() {
        prefetchers.forEach { $0.cancel() }
    }
}
