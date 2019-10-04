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
    
    override func showNoDataView() {
        super.showNoDataView()
        let noDataView = UIView()
        let lbl = UILabel()
        lbl.textColor = .lightGray
        lbl.font = .systemFont(ofSize: 15, weight: .medium)
        lbl.text = "You haven't added a favorite yet. If you want to set a favorite picture, click the star icon in any picture."
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        noDataView.addSubview(lbl)
        lbl.pinEdgesToSuperview(insets: .init(top: 0, left: 16, bottom: 0, right: -16))
        collectionView.backgroundView = noDataView
    }
}
