//
//  FavoriteItemsPageController.swift
//  Core
//
//  Created by Atilla Özder on 25.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation

class FavoriteItemsPageController: ImagePageController {
    
    override init() {
        super.init()
        self.viewModel = FavoriteItemsViewModel()
    }
    
    override func loadCollectionView() -> UICollectionView {
        let cv = super.loadCollectionView()
        cv.prefetchDataSource = self
        cv.delegate = self
        return cv
    }
}
