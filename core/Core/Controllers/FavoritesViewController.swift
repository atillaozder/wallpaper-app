//
//  FavoritesViewController.swift
//  Core
//
//  Created by Atilla Özder on 25.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import GoogleMobileAds

class FavoritesViewController: ImageListViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        InterstitialHandler.shared().increase()
    }
    
    override func setupViews() {
        super.setupViews()
        self.navigationItem.title = Localization.favorites
    }
}
