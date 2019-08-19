//
//  CategoryViewModel.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class CategoryViewModel: PagedViewModel<CategoryCellViewModel> {
    
    struct Input: PagedViewModelInput {
        var currentPage: Int
        var endDragging: BehaviorRelay<Bool?>
        var loadPageTrigger: PublishSubject<Void>
        var loadNextPageTrigger: PublishSubject<Void>
        var viewState: PublishSubject<ViewState>
        
        init() {
            self.currentPage = 1
            self.endDragging = BehaviorRelay(value: nil)
            self.loadPageTrigger = PublishSubject()
            self.loadNextPageTrigger = PublishSubject()
            self.viewState = PublishSubject()
        }
    }
    
    struct Output: PagedViewModelOutput {
        var viewModels: BehaviorRelay<[Identifiable]>
        var dataSource: Driver<[Identifiable]>
        let loadingIndicator: ActivityIndicator
        let nextPageIndicator: ActivityIndicator
        var isPageLoading: Driver<Bool>
        var isNextPageLoading: Driver<Bool>
        var viewState: Observable<ViewState>
        var hasNextPage: Bool
        var isEmpty: Bool {
            return viewModels.value.isEmpty
        }
        
        init(input: PagedViewModelInput) {
            self.loadingIndicator = ActivityIndicator()
            self.nextPageIndicator = ActivityIndicator()
            self.isPageLoading = loadingIndicator.asDriver()
            self.isNextPageLoading = nextPageIndicator.asDriver()
            self.hasNextPage = false
            self.viewState = input.viewState.asObservable()
            self.viewModels = BehaviorRelay(value: [])
            self.dataSource = viewModels.asDriver(onErrorJustReturn: [])
        }
    }
    
    private(set) var input: PagedViewModelInput
    private(set) var output: PagedViewModelOutput
    
    override var pageInput: PagedViewModelInput! {
        get { return input }
        set { input.currentPage = newValue.currentPage }
    }
    
    override var pageOutput: PagedViewModelOutput! {
        get { return output }
        set { output.hasNextPage = newValue.hasNextPage }
    }
    
    override init() {
        self.input = Input()
        self.output = Output(input: input)
        super.init()
    }
    
    override func getPageRequest() -> URLRequestConfigurable? {
        return Router.category(page: input.currentPage)
    }
    
    override func fetchData() -> Observable<[CategoryCellViewModel]> {
        return fetchMapper(PagedCategory.self)
    }
    
    override func map<U>(_ response: U) -> [CategoryCellViewModel] where U : Paginatable {
        super.map(response)
        return (response as! PagedCategory)
            .items
            .map { return CategoryCellViewModel(category: $0) }
    }
    
}
