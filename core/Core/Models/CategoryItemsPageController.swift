//
//  CategoryItemsPageController.swift
//  Core
//
//  Created by Atilla Özder on 4.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import UIKit

class CategoryItemsPageController: ImagePageController {
    
    convenience init(viewModel: CategoryItemsViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func loadCollectionView() -> UICollectionView {
        let cv = super.loadCollectionView()
        cv.prefetchDataSource = self
        cv.delegate = self
        return cv
    }
}
