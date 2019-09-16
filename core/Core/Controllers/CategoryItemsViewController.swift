//
//  CategoryItemsViewController.swift
//  Core
//
//  Created by Atilla Özder on 4.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

class CategoryItemsViewController: ImageListViewController {
    
    private var _viewModel: CategoryItemsViewModel {
        return viewModel as! CategoryItemsViewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        InterstitialHandler.shared().increase()
    }
    
    override func setupViews() {
        super.setupViews()
        self.navigationItem.title = _viewModel.navigationTitle
    }
}
