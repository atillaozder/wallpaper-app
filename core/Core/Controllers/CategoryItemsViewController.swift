//
//  CategoryItemsViewController.swift
//  Core
//
//  Created by Atilla Özder on 4.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import UIKit
import GoogleMobileAds

class CategoryItemsViewController: UIViewController {
    
    private var categoryItemsViewModel: CategoryItemsViewModel
    private(set) lazy var pageController: CategoryItemsPageController = {
        return CategoryItemsPageController(viewModel: categoryItemsViewModel)
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
    
    init(viewModel: CategoryItemsViewModel) {
        self.categoryItemsViewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.categoryItemsViewModel = CategoryItemsViewModel()
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
        self.navigationItem.title = categoryItemsViewModel.navigationTitle
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

extension CategoryItemsViewController: GADBannerViewDelegate {
    public func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        var insets = UIEdgeInsets.zero
        insets.bottom = bannerView.frame.height
        collectionView.contentInset = insets
        collectionView.scrollIndicatorInsets = insets
    }
}

extension CategoryItemsViewController: PageControllerDelegate {
    func pageController(_ pageController: PageController, didSelectItem item: CellViewModelType) {
        switch item {
        case .image(let cvm):
            presentImageScreen(cvm.item)

        default:
            break
        }
    }
}

extension CategoryItemsViewController: InterstitialHandlerDelegate {
    func interstitialHandler(_ handler: InterstitialHandler,
                             willPresentInterstitial interstitial: GADInterstitial) {
        interstitial.present(fromRootViewController: self)
        DispatchQueue.main.async {
            if let refreshControl = self.collectionView.refreshControl,
                refreshControl.isRefreshing {
                refreshControl.endRefreshing()
            }
        }
    }
}
