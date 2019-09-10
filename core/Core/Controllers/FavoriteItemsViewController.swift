//
//  FavoriteItemsViewController.swift
//  Core
//
//  Created by Atilla Özder on 25.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import UIKit
import GoogleMobileAds

class FavoriteItemsViewController: UIViewController {
    
    private(set) lazy var pageController: FavoriteItemsPageController = {
        return FavoriteItemsPageController()
    }()
    
    lazy var bannerView: GADBannerView = {
        return getBannerView()
    }()
    
    var viewModel: PagedViewModelType {
        return pageController.viewModel
    }
    
    unowned var collectionView: UICollectionView {
        return pageController.collectionView
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        InterstitialHandler.shared().setDelegate(self)
        InterstitialHandler.shared().increase()
        self.setupViews()
        pageController.delegate = self
        pageController.load()
        pageController.bind()
    }
    
    private func setupViews() {
        self.navigationItem.title = Localization.favorites
        self.view.backgroundColor = .white
        
        self.view.addSubview(collectionView)
        collectionView.pinEdgesToView(view, insets: .zero, exclude: [.top])
        if #available(iOS 11.0, *) {
            collectionView.pinTop(to: view.safeTopAnchor)
        } else {
            collectionView.pinTop(to: topLayoutGuide.bottomAnchor)
        }
        
        pageController.setupViews()
        self.view.insertSubview(bannerView, at: 1)
        bannerView.pinCenterX(to: view.centerXAnchor)
        bannerView.pinBottom(to: view.safeBottomAnchor)
        bannerView.delegate = self
    }
}

extension FavoriteItemsViewController: GADBannerViewDelegate {
    public func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        var insets = UIEdgeInsets.zero
        insets.bottom = bannerView.frame.height
        collectionView.contentInset = insets
        collectionView.scrollIndicatorInsets = insets
    }
}

extension FavoriteItemsViewController: PageControllerDelegate {
    func pageController(_ pageController: PageController, didSelectItem item: CellViewModelType) {
        switch item {
        case .image(let cvm):
            presentImageScreen(cvm.item)
        default:
            break
        }
    }
}

extension FavoriteItemsViewController: InterstitialHandlerDelegate {
    func interstitialHandler(_ handler: InterstitialHandler,
                             willPresentInterstitial interstitial: GADInterstitial) {
        interstitial.present(fromRootViewController: self)
        if let refreshControl = self.collectionView.refreshControl,
            refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }
}
