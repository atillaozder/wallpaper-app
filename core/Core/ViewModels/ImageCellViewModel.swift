//
//  ImageCellViewModel.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation

class ImageCellViewModel: Identifiable, ImageFetchable {
    
    var item: Image
    var imageUrl: URL? {
        return item.image?.asURL()
    }
    
    var portraitImagePrefetcher: ImagePrefetcher
    var prefetchers: [ImagePrefetcher]
    
    class var imageTransformer: ImageTransformer {
        return ImageTransformer(size: UIConstants.kItemSize,
                                fillColor: .defaultImageBackground,
                                contentMode: .scaleToFill)
    }
    
    var identifier: String {
        return "\(item.id)"
    }
    
    init(item: Image) {
        self.item = item
        self.portraitImagePrefetcher = ImagePrefetcher(
            url: item.image?.asURL(),
            transformer: ImageCellViewModel.imageTransformer)
        self.prefetchers = [portraitImagePrefetcher]
    }
    
    func set(_ object: Identifiable) {
        guard let cvm = object as? ImageCellViewModel else { return }
        self.portraitImagePrefetcher = cvm.portraitImagePrefetcher
    }
}
