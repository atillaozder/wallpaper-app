//
//  PagedViewModel.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class PagedViewModel<T: Identifiable>: PagedViewModelType {
    
    private(set) var bag: DisposeBag
    let backgroundWorkScheduler: ImmediateSchedulerType
    private lazy var previousPage = self.pageInput.currentPage
    
    var pageInput: PagedViewModelInput! {
        get { return nil }
        set {}
    }
    
    var pageOutput: PagedViewModelOutput! {
        get { return nil }
        set {}
    }
    
    var source: [T] {
        get { return pageOutput.viewModels.value as! [T] }
        set {
            pageOutput.viewModels.accept(newValue)
            let state: ViewState = newValue.isEmpty ? .noData : .loaded
            pageInput.viewState.onNext(state)
        }
    }
    
    init() {
        self.bag = DisposeBag()
        self.backgroundWorkScheduler = ConcurrentDispatchQueueScheduler(qos: .background)
    }
    
    func viewDidLoad() {
        self.initializeObservers()
        self.load()
    }
    
    func initializeObservers() {
        self.observePageTriggers()
        self.observeError()
    }
    
    func cellViewModel(at index: Int) -> Identifiable? {
        guard index < source.count else { return nil }
        return source[index]
    }
    
    func getPageRequest() -> URLRequestConfigurable? {
        return nil
    }
    
    func fetchData() -> Observable<[T]> {
        return .empty()
    }
    
    func fetchMapper<U>(_ type: U.Type) -> Observable<[T]> where U: Paginatable {
        guard let urlReqConv = getPageRequest() else { return .empty() }
        return ApiService.shared()
            .request(urlReqConv, type: U.self)
            .subscribeOn(backgroundWorkScheduler)
            .observeOn(backgroundWorkScheduler)
            .catchError { [weak self] (err) -> Observable<U> in
                guard let `self` = self else { return .empty() }
                self.pageInput.viewState.onNext(.error(err.asApiError))
                return .empty()
            }.flatMap { [weak self] (response) -> Observable<[T]> in
                guard let `self` = self else { return .empty() }
                let dataSource = self.map(response)
                return .just(dataSource)
        }
    }
    
    @discardableResult
    func map<U>(_ response: U) -> [T] where U: Paginatable {
        self.pageOutput.hasNextPage = !response.next.stringValue.isEmpty
        return []
    }
    
    func scrollViewWillBeginDragging() {
        pageInput.endDragging.accept(nil)
    }
    
    func scrollViewWillEndDragging() {
        pageInput.endDragging.accept(true)
    }
    
    func collectionView(willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let viewModel = cellViewModel(at: indexPath.item) as? CellImagePrefetcher {
            viewModel.fetchImages()
        }
    }
    
    func collectionView(prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let viewModel = cellViewModel(at: indexPath.item) as? CellImagePrefetcher {
                viewModel.fetchImages()
            }
        }
    }
    
    func collectionView(cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let viewModel = cellViewModel(at: indexPath.item) as? CellImagePrefetcher {
                viewModel.cancelFetching()
            }
        }
    }
    
    func reloadData() {
        pageOutput.viewModels.accept([])
        self.load()
    }
    
    func load() {
        self.pageInput.loadPageTrigger.onNext(())
    }
    
    func loadNextPage() {
        if pageOutput.hasNextPage == true {
            self.pageInput.loadNextPageTrigger.onNext(())
        }
    }
    
    func observePageTriggers() {
        let pageRequest = self.pageOutput.isPageLoading
            .asObservable()
            .sample(self.pageInput.loadPageTrigger)
            .observeOn(backgroundWorkScheduler)
            .flatMap { [weak self] (isPageLoading) -> Observable<[T]> in
                guard let `self` = self else { return .empty() }
                if isPageLoading {
                    return .empty()
                } else {
                    self.pageInput.currentPage = 1
                    return self.fetchData()
                        .trackActivity(self.pageOutput.loadingIndicator)
                }
            }.share(replay: 1)
        
        let nextPageRequest = self.pageOutput.isNextPageLoading
            .asObservable()
            .sample(self.pageInput.loadNextPageTrigger)
            .observeOn(backgroundWorkScheduler)
            .flatMap { [weak self] (isNextPageLoading) -> Observable<[T]> in
                guard let `self` = self else { return .empty() }
                if isNextPageLoading {
                    return .empty()
                } else {
                    self.previousPage = self.pageInput.currentPage
                    self.pageInput.currentPage += 1
                    return self.fetchData()
                        .trackActivity(self.pageOutput.nextPageIndicator)
                }
            }.share(replay: 1)
        
        let merged = Observable.of(pageRequest, nextPageRequest).merge().share(replay: 1)
        let sequence = Observable
            .combineLatest(pageOutput.viewModels.asObservable(), merged)
            .sample(merged)
            .map { [weak self] current, request -> [Identifiable] in
                guard let `self` = self else { return current }
                return self.pageInput.currentPage == 1 ? self.merge(request, current) : self.distinct(current + request)
            }.catchErrorJustReturn([])
        
        sequence.bind(to: pageOutput.viewModels).disposed(by: bag)
        sequence
            .do(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.previousPage = self.pageInput.currentPage
            }).map { (dataSource) -> ViewState in
                return dataSource.isEmpty ? .noData : .loaded
            }.bind(to: pageInput.viewState)
            .disposed(by: bag)
    }
    
    private func observeError() {
        pageOutput.viewState
            .filter { return $0 == ViewState.error(.invalidData) }
            .filter { [weak self] (_) -> Bool in
                guard let `self` = self else { return false }
                return self.previousPage != self.pageInput.currentPage
            }.subscribe(onNext: { _ in
                self.pageInput.currentPage = self.previousPage
            }).disposed(by: bag)
    }
    
    private func merge(_ request: [Identifiable], _ current: [Identifiable]) -> [Identifiable] {
        let slicedCurrent = Array(current.prefix(request.count))
        let merged = request + slicedCurrent
        
        return merged.reduce(into: [Identifiable]()) { elements, element in
            if let addedBefore = elements.first(where: { $0.isEqual(element) }) {
                addedBefore.set(element)
            } else {
                elements.append(element)
            }
        }
    }
    
    private func distinct(_ arr: [Identifiable]) -> [Identifiable] {
        return arr.reduce(into: []) { elements, element in
            if !elements.contains(where: { $0.identifier == element.identifier }) {
                elements.append(element)
            }
        }
    }
}
