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
    
    override func presentImages(source: [ImageCellViewModel], startFrom index: Int) {
        let viewController = DetailViewController(images: source, startFrom: index)
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    override func showNoDataView() {
        super.showNoDataView()
        let noDataView = UIView()
        let lbl = UILabel()
        lbl.textColor = .lightGray
        lbl.font = .systemFont(ofSize: 15, weight: .medium)
        lbl.text = "You haven't added a favorite yet. If you set any favorite photo by clicking the star icon in detail page of the photo, you will see it in here."
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        noDataView.addSubview(lbl)
        lbl.pinEdgesToSuperview(insets: .init(top: 0, left: 16, bottom: 0, right: -16))
        collectionView.backgroundView = noDataView
    }
}
