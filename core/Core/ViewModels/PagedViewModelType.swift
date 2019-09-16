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

protocol PagedViewModelType: DataSourceViewModelType {
    var pageInput: PagedViewModelInput! { get set }
    var pageOutput: PagedViewModelOutput! { get set }
    var bag: DisposeBag { get }
    func viewDidLoad()
    func load()
    func loadNextPage()
    func onRefresh()
    func reloadData()
    func initializeObservers()
    func observePageTriggers()
    func getPageRequest() -> URLRequestConfigurable?
}

protocol PagedViewModelInput {
    var currentPage: Int { get set }
    var isDragging: BehaviorRelay<Bool?> { get }
    var loadPageTrigger: PublishSubject<Void> { get }
    var loadNextPageTrigger: PublishSubject<Void> { get }
    var state: PublishSubject<ViewState> { get }
}

protocol PagedViewModelOutput {
    var hasNextPage: Bool { get set }
    var isEmpty: Bool { get }
    var loadingIndicator: ActivityIndicator { get }
    var nextPageIndicator: ActivityIndicator { get }
    var isPageLoading: Driver<Bool> { get }
    var isNextPageLoading: Driver<Bool> { get }
    var state: Observable<ViewState> { get }
    var viewModels: BehaviorRelay<[Identifiable]> { get }
}
