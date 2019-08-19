//
//  ImageCell.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import UIKit

class ImageCell: PagedCollectionCell {
    
    override func setup() {
        super.setup()
        pageController.viewModel = ImageViewModel()
    }
    
    override func getPageController() -> PageController {
        return ImagePageController()
    }
    
    override func setDelegates(_ delegate: PageControllerDelegate?) {
        super.setDelegates(delegate)
        let controller = pageController as! ImagePageController
        controller.delegate = delegate
    }
}
