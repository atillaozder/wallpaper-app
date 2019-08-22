//
//  HomeViewController.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import UIKit
import GoogleMobileAds

public class HomeViewController: UIViewController {
    
    private let dataSource = [Localization.recent, Localization.category]
    
    private enum DataSourceSections: Int {
        case images = 0
        case categories = 1
    }
    
    lazy var menuBar: MenuBar = {
        let mb = MenuBar()
        mb.dataSource = dataSource
        mb.delegate = self
        return mb
    }()
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = .zero
        flowLayout.headerReferenceSize = .zero
        flowLayout.footerReferenceSize = .zero
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        cv.backgroundColor = .white
        cv.decelerationRate = .fast
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.contentInset = .init(top: MenuBar.barHeight, left: 0, bottom: 0, right: 0)
        cv.scrollIndicatorInsets = .init(top: MenuBar.barHeight, left: 0, bottom: 0, right: 0)
        cv.dataSource = self
        cv.delegate = self
        cv.isPagingEnabled = true
        cv.bounces = false
        return cv
    }()
    
    lazy var bannerView: GADBannerView = {
        return getBannerView()
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        InterstitialHandler.shared().setDelegate(self)
    }
    
    private func setupViews() {
        self.navigationItem.title = Bundle.main.displayName
        self.view.backgroundColor = .white
        
        self.view.addSubview(collectionView)
        collectionView.pinEdgesToView(view, insets: .zero, exclude: [.top])
        collectionView.registerCell(ImageCell.self)
        collectionView.registerCell(CategoryCell.self)
        
        self.view.insertSubview(menuBar, at: 1)
        menuBar.pinEdgesToView(view, insets: .zero, exclude: [.top, .bottom])
        menuBar.pinHeight(to: MenuBar.barHeight)
        
        if #available(iOS 11.0, *) {
            collectionView.pinTop(to: view.safeTopAnchor)
            menuBar.pinTop(to: view.safeTopAnchor)
        } else {
            collectionView.pinTop(to: topLayoutGuide.bottomAnchor)
            menuBar.pinTop(to: topLayoutGuide.bottomAnchor)
        }
        
        self.view.insertSubview(bannerView, at: 1)
        bannerView.pinCenterX(to: view.centerXAnchor)
        bannerView.pinBottom(to: view.safeBottomAnchor)
        bannerView.delegate = self
    }
}

extension HomeViewController: GADBannerViewDelegate {
    public func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        var insets = UIEdgeInsets.zero
        insets.top = MenuBar.barHeight
        insets.bottom = bannerView.frame.height
        collectionView.contentInset = insets
        collectionView.scrollIndicatorInsets = insets
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

extension HomeViewController: InterstitialHandlerDelegate {
    func interstitialHandler(_ handler: InterstitialHandler,
                             didShowInterstitial interstitial: GADInterstitial) {
        if viewIfLoaded?.window != nil {
            interstitial.present(fromRootViewController: self)
        }
    }
}

extension HomeViewController: MenuBarDelegate {
    func menuBar(_ menuBar: MenuBar, didScrollAt indexPath: IndexPath) {
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
}

extension HomeViewController: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let section = DataSourceSections(rawValue: indexPath.item) {
            switch section {
            case .images:
                let cell = collectionView.dequeueReusableCell(for: indexPath) as ImageCell
                cell.load()
                cell.setDelegates(self)
                return cell
            case .categories:
                let cell = collectionView.dequeueReusableCell(for: indexPath) as CategoryCell
                cell.load()
                cell.setDelegates(self)
                return cell
            }
        }
        
        return CollectionCell()
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let size = scrollView.bounds.size
        let offset = scrollView.contentOffset
        menuBar.barLeftAnchorConstraint?.constant = offset.x / CGFloat(dataSource.count)
        
        let index = ((offset.x - size.width) / size.width) + 1
        if index.truncatingRemainder(dividingBy: 1) == 0 {
            menuBar.scroll(at: Int(index))
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        let insets = collectionView.contentInset
        let height = collectionView.bounds.height - insets.top - insets.bottom
        return .init(width: collectionView.bounds.width, height: height)
    }
}

extension HomeViewController: PageControllerDelegate {
    func pageController(_ pageController: PageController, didSelectItem item: CellViewModelType) {
        switch item {
        case .image(let cvm):
            let viewController = PhotoViewController(imageUrl: cvm.imageUrl)
            self.navigationController?.pushViewController(viewController, animated: true)
        case .category(let cvm):
            let viewModel = CategoryItemsViewModel(category: cvm.category)
            let viewController = CategoryItemsViewController(viewModel: viewModel)
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}


