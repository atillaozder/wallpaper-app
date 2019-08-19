//
//  PageController.swift
//  Core
//
//  Created by Atilla Özder on 4.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

private let footerReuseId = "footerReuseId"

class PageController: NSObject {
    
    private(set) var bag: DisposeBag = DisposeBag()
    lazy var mainScheduler: SerialDispatchQueueScheduler = MainScheduler.instance
    lazy var backgroundWorkScheduler: ImmediateSchedulerType = ConcurrentDispatchQueueScheduler(qos: .default)
    lazy var refreshControl: UIRefreshControl = UIRefreshControl()
    
    lazy var collectionView: UICollectionView = {
        return loadCollectionView()
    }()
    
    lazy var loadingIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .gray)
        ai.hidesWhenStopped = true
        return ai
    }()
    
    lazy var pageIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .gray)
        ai.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
        ai.hidesWhenStopped = true
        return ai
    }()
    
    var viewModel: PagedViewModelType! {
        didSet {
            onViewModelDidSet()
        }
    }
    
    override init() {
        super.init()
    }
    
    func onViewModelDidSet() {
        return
    }
    
    func setDataSource() {
        return
    }
    
    func loadCollectionView() -> UICollectionView {
        return UICollectionView(frame: .zero)
    }
    
    func dispose() {
        self.bag = DisposeBag()
    }
    
    func setupViews() {
        collectionView.refreshControl = refreshControl
        collectionView.register(UICollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: footerReuseId)
    }
    
    func load() {
        setDataSource()
        viewModel.viewDidLoad()
        startIndicators()
    }
    
    func bind() {        
        refreshControl.rx
            .controlEvent(.valueChanged)
            .sample(viewModel.pageInput.endDragging.asObservable())
            .debounce(.milliseconds(250), scheduler: mainScheduler)
            .bind(to: viewModel.pageInput.loadPageTrigger)
            .disposed(by: bag)
        
        collectionView.rx_nextPageTrigger
            .subscribeOn(backgroundWorkScheduler)
            .flatMapLatest { [weak self] (_) -> Observable<Void> in
                guard let `self` = self else { return .empty() }
                let output = self.viewModel.pageOutput!
                return (output.hasNextPage && !output.isEmpty) ? .just(()) : .empty()
            }.bind(to: viewModel.pageInput.loadNextPageTrigger)
            .disposed(by: bag)
        
        viewModel.pageOutput
            .isPageLoading
            .drive(onNext: { [weak self] (isPageLoading) in
                guard let `self` = self else { return }
                isPageLoading ? self.startIndicators() : self.stopIndicators()
            }).disposed(by: bag)
        
        viewModel.pageOutput
            .isNextPageLoading
            .drive(onNext: { [weak self] (isNextPageLoading) in
                guard let `self` = self else { return }
                isNextPageLoading ? self.showNextPageIndicator() : self.hideNextPageIndicator()
            }).disposed(by: bag)
        
        viewModel.pageOutput
            .viewState
            .asDriver(onErrorJustReturn: .error(.invalidData))
            .drive(onNext: { [weak self] (viewState) in
                guard let `self` = self else { return }
                self.handleState(viewState)
            }).disposed(by: bag)
    }
    
    private func setBackgroundView(_ backgroundView: UIView?) {
        DispatchQueue.main.async {
            self.collectionView.backgroundView = backgroundView
        }
    }
    
    func startIndicators() {
        guard !refreshControl.isRefreshing else { return }
        if !loadingIndicator.isAnimating {
            self.loadingIndicator.startAnimating()
        }
        self.setBackgroundView(loadingIndicator)
    }
    
    func stopIndicators() {
        self.refreshControl.endRefreshing()
        self.loadingIndicator.stopAnimating()
        self.hideNextPageIndicator()
    }
    
    func showNextPageIndicator() {
        let lastSection = self.collectionView.numberOfSections - 1
        let lastItem = self.collectionView.numberOfItems(inSection: lastSection) - 1
        let indexPath = IndexPath(item: lastItem, section: lastSection)
        
        collectionView.collectionViewLayout.prepare()
        
        let elementKindFooter = UICollectionView.elementKindSectionFooter
        let footerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: elementKindFooter,
            withReuseIdentifier: footerReuseId,
            for: indexPath
        )
        
        self.pageIndicator.startAnimating()
        footerView.addSubview(pageIndicator)
        pageIndicator.pinCenterOfSuperview()
    }
    
    func hideNextPageIndicator() {
        self.pageIndicator.superview?.removeFromSuperview()
        self.pageIndicator.removeFromSuperview()
        self.pageIndicator.stopAnimating()
    }
    
    func handleState(_ state: ViewState) {
        switch state {
        case .noData:
            onNoData()
        case .loaded:
            onLoaded()
        case .error(let apiError):
            onLoaded()
            onError(apiError)
        }
    }
    
    func onNoData() {
        #if DEBUG
        print("No Data \(String(describing: type(of: self)))")
        #endif
    }
    
    func onLoaded() {
        #if DEBUG
        print("Loaded \(String(describing: type(of: self)))")
        #endif
    }
    
    func onError(_ err: ApiError) {
        self.stopIndicators()
        #if DEBUG
        print("Error \(String(describing: type(of: self))) \(err.description)")
        #endif
    }
}

extension PageController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        viewModel.collectionView(willDisplay: cell, forItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        let footerHeight: CGFloat = viewModel.pageOutput.hasNextPage ? 44 : 0.01
        return CGSize(width: collectionView.bounds.width, height: footerHeight)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        viewModel.scrollViewWillBeginDragging()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        viewModel.scrollViewWillEndDragging()
    }
}

extension PageController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView,
                        prefetchItemsAt indexPaths: [IndexPath]) {
        viewModel.collectionView(prefetchItemsAt: indexPaths)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        viewModel.collectionView(cancelPrefetchingForItemsAt: indexPaths)
    }
}
