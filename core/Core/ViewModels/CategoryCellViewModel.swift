//
//  CategoryCellViewModel.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation
import class UIKit.UIScreen

class CategoryCellViewModel: Identifiable, CellImagePrefetcher {
    
    var category: Category
    var landImagePrefetcher: ImagePrefetcher
    var categoryNameText: String
    var prefetchers: [ImagePrefetcher]
    
    class var imageTransformer: ImageTransformer {
        var width = UIScreen.main.bounds.width
        width -= UIConstants.kImageEdgeInsets.left
        width -= UIConstants.kImageEdgeInsets.right
        return ImageTransformer(size: .init(width: width, height: 200),
                                fillColor: .defaultImageBackground,
                                alpha: 0.6)
    }
    
    var identifier: String {
        return "\(category.id)"
    }
    
    init(category: Category) {
        self.category = category
        self.categoryNameText = category.name
        self.landImagePrefetcher = ImagePrefetcher(url: category.image?.asURL(), transformer: CategoryCellViewModel.imageTransformer)
        self.prefetchers = [landImagePrefetcher]
    }
    
    func set(_ object: Identifiable) {
        guard let cvm = object as? CategoryCellViewModel else { return }
        self.landImagePrefetcher = cvm.landImagePrefetcher
    }
}
