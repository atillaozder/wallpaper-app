//
//  CategoryCell.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import UIKit

class CategoryCell: PagedCollectionCell {
    
    override func setup() {
        super.setup()
        pageController.viewModel = CategoryViewModel()
    }
    
    override func getPageController() -> PageController {
        return CategoryPageController()
    }
    
    override func setDelegates(_ delegate: PageControllerDelegate?) {
        super.setDelegates(delegate)
        let controller = pageController as! CategoryPageController
        controller.delegate = delegate
    }
}
