//
//  PagedViewModelType.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol PagedViewModelType {
    var pageInput: PagedViewModelInput! { get set }
    var pageOutput: PagedViewModelOutput! { get set }
    var bag: DisposeBag { get }
    var backgroundWorkScheduler: ImmediateSchedulerType { get }
    func viewDidLoad()
    func load()
    func loadNextPage()
    func reloadData()
    func initializeObservers()
    func observePageTriggers()
    func getPageRequest() -> URLRequestConfigurable?
    func cellViewModel(at index: Int) -> Identifiable?
    func scrollViewWillBeginDragging()
    func scrollViewWillEndDragging()
    func collectionView(willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    func collectionView(prefetchItemsAt indexPaths: [IndexPath])
    func collectionView(cancelPrefetchingForItemsAt indexPaths: [IndexPath])
}

protocol PagedViewModelInput {
    var currentPage: Int { get set }
    var endDragging: BehaviorRelay<Bool?> { get }
    var loadPageTrigger: PublishSubject<Void> { get }
    var loadNextPageTrigger: PublishSubject<Void> { get }
    var viewState: PublishSubject<ViewState> { get }
}

protocol PagedViewModelOutput {
    var hasNextPage: Bool { get set }
    var isEmpty: Bool { get }
    var loadingIndicator: ActivityIndicator { get }
    var nextPageIndicator: ActivityIndicator { get }
    var isPageLoading: Driver<Bool> { get }
    var isNextPageLoading: Driver<Bool> { get }
    var viewState: Observable<ViewState> { get }
    var viewModels: BehaviorRelay<[Identifiable]> { get }
    var dataSource: Driver<[Identifiable]> { get }
}
