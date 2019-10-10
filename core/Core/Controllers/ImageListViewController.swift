//
//  ImageListViewController.swift
//  Core
//
//  Created by Atilla Özder on 16.09.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import RxSwift
import RxCocoa
import GoogleMobileAds

class ImageListViewController: PagedCollectionViewController {
    
    var viewModel: ImageViewModel!
    
    override var pageViewModel: PagedViewModelType! {
        return viewModel
    }
    
    override init() {
        super.init()
        viewModel = ImageViewModel()
    }

    convenience init(viewModel: ImageViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        viewModel = ImageViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        InterstitialHandler.shared().setDelegate(self)
    }

    override func getCollectionView() -> UICollectionView {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = ImageCellViewModel.imageTransformer.size
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
            .do(onNext: { [weak self] (arr) in
                guard let `self` = self else { return }
                arr.isEmpty ? self.showNoDataView() : self.hideNoDataView()
            }).drive(collectionView.rx.items(
                cellIdentifier: ImageCell.identifier,
                cellType: ImageCell.self)) { (item, identifiable, cell) in
                    if let cellView = cell.cellView {
                        cellView.bind(to: identifiable)
                    } else {
                        let cellView = ImageCellView()
                        cellView.bind(to: identifiable)
                        cell.cellView = cellView
                    }
            }.disposed(by: bag)
    }
    
    func showNoDataView() {
        return
    }
    
    func hideNoDataView() {
        collectionView.backgroundView = nil
    }
    
    func presentImages(source: [ImageCellViewModel], startFrom index: Int) {
        let viewController = DetailViewController(images: source.incremented(count: 10000),
                                                  startFrom: index)
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension ImageListViewController: InterstitialHandlerDelegate {
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

extension ImageListViewController {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let id = viewModel.cellViewModel(at: indexPath.item)?.identifier ?? ""
        let index = viewModel.source.firstIndex(where: { $0.identifier == id }) ?? 0
        self.presentImages(source: viewModel.source, startFrom: index)
    }
}
