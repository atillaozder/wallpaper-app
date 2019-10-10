//
//  PagedCollectionViewController.swift
//  Core
//
//  Created by Atilla Özder on 16.09.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import RxSwift
import GoogleMobileAds

class PagedCollectionViewController: ViewController {
    
    private let footerReuseId = "footerReuseId"
    private var footerHeight: CGFloat {
        return (pageViewModel != nil && pageViewModel.pageOutput.hasNextPage) ?
            UIConstants.kNextPageIndicatorHeight :
            0.01
    }
    
    lazy var collectionView: UICollectionView = {
        return getCollectionView()
    }()
    
    var defaultInsets: UIEdgeInsets {
        return .zero
    }
    
    func getCollectionView() -> UICollectionView {
        return UICollectionView(frame: .zero)
    }
    
    override func setupViews() {
        super.setupViews()
        collectionView.register(
            UICollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: footerReuseId)
        
        setupCollectionView()
        setupBanner()
    }
    
    func setupCollectionView() {
        view.addSubview(collectionView)
        if #available(iOS 11.0, *) {
            collectionView.pinEdgesToSuperview()
        } else {
            collectionView.pinEdgesToView(view, exclude: [.top])
            collectionView.pinTop(to: topLayoutGuide.bottomAnchor)
        }
    }
    
    func setupBanner() {
        self.view.insertSubview(bannerView, at: 1)
        bannerView.pinCenterX(to: view.centerXAnchor)
        bannerView.pinBottom(to: view.safeBottomAnchor)
        bannerView.delegate = self
    }
    
    override func initInputBinding() {
        super.initInputBinding()
        
        collectionView.rx_nextPageTrigger
            .subscribeOn(concurrentWorkScheduler)
            .flatMapLatest { [weak self] (_) -> Observable<Void> in
                guard let `self` = self else { return .empty() }
                let output = self.pageViewModel.pageOutput!
                return (output.hasNextPage && !output.isEmpty) ? .just(()) : .empty()
            }.bind(to: pageViewModel.pageInput.loadNextPageTrigger)
            .disposed(by: bag)
        
        collectionView.rx
            .willBeginDragging
            .do(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.willBeginDragging()
            }).map { (_) -> Bool? in
                return nil
            }.bind(to: pageViewModel.pageInput.isDragging)
            .disposed(by: bag)
        
        collectionView.rx
            .willEndDragging
            .do(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.willEndDragging()
            }).map { (_) -> Bool? in
                return true
            }.bind(to: pageViewModel.pageInput.isDragging)
            .disposed(by: bag)
    }
    
    override func setBackgroundView(_ backgroundView: UIView?) {
        self.collectionView.backgroundView = backgroundView
    }
    
    override func showNextPageIndicator() {
        let lastSection = self.collectionView.numberOfSections - 1
        let lastItem = self.collectionView.numberOfItems(inSection: lastSection) - 1
        let indexPath = IndexPath(item: lastItem, section: lastSection)
        
        collectionView.collectionViewLayout.prepare()
        
        let footerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: footerReuseId,
            for: indexPath)
        
        super.showNextPageIndicator()
        footerView.addSubview(pageIndicator)
        pageIndicator.pinCenterOfSuperview()
    }
    
    override func hideNextPageIndicator() {
        super.hideNextPageIndicator()
        pageIndicator.superview?.removeFromSuperview()
        pageIndicator.removeFromSuperview()
    }
}

extension PagedCollectionViewController: GADBannerViewDelegate {
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
        
        var insets = defaultInsets
        insets.bottom = bannerView.frame.height
        collectionView.contentInset = insets
        collectionView.scrollIndicatorInsets = insets
    }
}

extension PagedCollectionViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        self.cachedCellSizes[indexPath] = cell.frame.size
        pageViewModel?.willDisplayCell(for: .item, at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        pageViewModel?.didEndDisplayingCell(for: .item, at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        return .init(width: collectionView.bounds.width, height: footerHeight)
    }
}

extension PagedCollectionViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView,
                        prefetchItemsAt indexPaths: [IndexPath]) {
        pageViewModel?.prefetch(for: .item, at: indexPaths)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        pageViewModel?.cancelPrefetching(for: .item, at: indexPaths)
    }
}
