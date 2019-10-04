//
//  CategoryCellViewModel.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation

class CategoryCellViewModel: Identifiable, ImageFetchable {
    
    var category: Category
    var landImagePrefetcher: ImagePrefetcher
    var categoryNameText: String
    var prefetchers: [ImagePrefetcher]
    
    class var imageTransformer: ImageTransformer {
        var width = UIScreen.main.bounds.width
        width -= UIConstants.kImageEdgeInsets.left
        width -= UIConstants.kImageEdgeInsets.right
        return ImageTransformer(size: .init(width: width, height: 200),
                                fillColor: .imageBackground,
                                alpha: 0.20)
    }
    
    var identifier: String {
        return "\(category.id)"
    }
    
    init(category: Category) {
        self.category = category
        self.categoryNameText = category.name
        self.landImagePrefetcher = ImagePrefetcher(
            url: category.image?.asURL(),
            transformer: CategoryCellViewModel.imageTransformer)
        self.prefetchers = [landImagePrefetcher]
    }
    
    func set(_ object: Identifiable) {
        guard let cvm = object as? CategoryCellViewModel else { return }
        self.landImagePrefetcher = cvm.landImagePrefetcher
    }
    
    func getViewController() -> UIViewController {
        let viewModel = CategoryItemsViewModel(category: category)
        return CategoryItemsViewController(viewModel: viewModel)
    }
}
