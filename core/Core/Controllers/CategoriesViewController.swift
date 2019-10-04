//
//  CategoriesViewController.swift
//  Core
//
//  Created by Atilla Özder on 16.09.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation
import GoogleMobileAds

class CategoriesViewController: PagedCollectionViewController {
    
    private lazy var viewModel: CategoryViewModel = CategoryViewModel()
    
    override var pageViewModel: PagedViewModelType! {
        return viewModel
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        InterstitialHandler.shared().setDelegate(self)
    }
    
    override func getCollectionView() -> UICollectionView {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CategoryCellViewModel.imageTransformer.size
        flowLayout.sectionInset = UIConstants.kImageEdgeInsets
        flowLayout.minimumLineSpacing = UIConstants.kImageLineSpacing
        flowLayout.minimumInteritemSpacing = UIConstants.kImageInterItemSpacing
        flowLayout.scrollDirection = .vertical
        flowLayout.headerReferenceSize = .zero
        flowLayout.footerReferenceSize = .zero
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        cv.backgroundColor = .darkTheme
        cv.isPagingEnabled = false
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = true
        cv.alwaysBounceVertical = true
        cv.bounces = true
        cv.refreshControl = self.refreshControl
        cv.delegate = self
        cv.prefetchDataSource = self
        cv.registerCell(ImageCell.self)
        return cv
    }
    
    override func initOutputBinding() {
        super.initOutputBinding()
        viewModel.output
            .dataSource
            .drive(collectionView.rx.items(
                cellIdentifier: ImageCell.identifier,
                cellType: ImageCell.self)) { (item, identifiable, cell) in
                    if let cellView = cell.cellView {
                        cellView.bind(to: identifiable)
                    } else {
                        let cellView = LandImageCellView()
                        cellView.bind(to: identifiable)
                        cell.cellView = cellView
                    }
            }.disposed(by: bag)
    }
}

extension CategoriesViewController: InterstitialHandlerDelegate {
    func interstitialHandler(_ handler: InterstitialHandler,
                             willPresentInterstitial interstitial: GADInterstitial) {
        DispatchQueue.main.async {
            if self.viewIfLoaded?.window != nil {
                interstitial.present(fromRootViewController: self)
                if let refreshControl = self.collectionView.refreshControl,
                    refreshControl.isRefreshing {
                    refreshControl.endRefreshing()
                }
            }
        }
    }
}

extension CategoriesViewController {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        if let cvm = viewModel.cellViewModel(at: indexPath.item) as? CategoryCellViewModel {
            let viewModel = CategoryItemsViewModel(category: cvm.category)
            let viewController = CategoryItemsViewController(viewModel: viewModel)
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

