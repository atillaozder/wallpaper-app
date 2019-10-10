//
//  ImageViewModel.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ImageViewModel: PagedViewModel<ImageCellViewModel> {
    
    struct Input: PagedViewModelInput {
        var currentPage: Int
        var isDragging: BehaviorRelay<Bool?>
        var loadPageTrigger: PublishSubject<Void>
        var loadNextPageTrigger: PublishSubject<Void>
        var state: PublishSubject<ViewState>
        
        init() {
            self.currentPage = 1
            self.isDragging = BehaviorRelay(value: nil)
            self.loadPageTrigger = PublishSubject()
            self.loadNextPageTrigger = PublishSubject()
            self.state = PublishSubject()
        }
    }
    
    struct Output: PagedViewModelOutput {
        var viewModels: BehaviorRelay<[Identifiable]>
        var dataSource: Driver<[Identifiable]>
        let loadingIndicator: ActivityIndicator
        let nextPageIndicator: ActivityIndicator
        var isPageLoading: Driver<Bool>
        var isNextPageLoading: Driver<Bool>
        var state: Observable<ViewState>
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
            self.state = input.state.asObservable()
            self.viewModels = BehaviorRelay(value: [])
            self.dataSource = viewModels.asDriver(onErrorJustReturn: [])
        }
    }
    
    private(set) var input: Input
    private(set) var output: Output
    
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
        return Router.recent(page: input.currentPage)
    }
    
    override func fetchData() -> Observable<[ImageCellViewModel]> {
        return fetchMapper(PagedImage.self)
    }
    
    override func map<U>(_ response: U) -> [ImageCellViewModel] where U : Paginatable {
        super.map(response)
        return (response as! PagedImage)
            .items
            .map { return ImageCellViewModel(item: $0) }
            .incremented(count: 2500)
    }
    
}
