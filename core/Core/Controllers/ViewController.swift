//
//  ViewController.swift
//  Core
//
//  Created by Atilla Özder on 16.09.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import GoogleMobileAds
import RxSwift

class ViewController: UIViewController {
    
    var bag: DisposeBag
    private(set) var refreshControl: UIRefreshControl
    var cachedCellSizes: [IndexPath: CGSize]
    
    private(set) lazy var serialWorkScheduler = SerialDispatchQueueScheduler(qos: .background)
    private(set) lazy var concurrentWorkScheduler = ConcurrentDispatchQueueScheduler(qos: .background)
    private(set) lazy var mainScheduler = MainScheduler.instance
    
    var pageViewModel: PagedViewModelType! { return nil }
    
    lazy var loadingIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .gray)
        ai.hidesWhenStopped = true
        return ai
    }()
    
    lazy var pageIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .gray)
        var frame = CGRect.zero
        frame.size = .init(width: self.view.bounds.width, height: UIConstants.kNextPageIndicatorHeight)
        ai.frame = frame
        ai.hidesWhenStopped = true
        return ai
    }()

    lazy var bannerView: GADBannerView = {
        return getBannerView()
    }()
    
    init() {
        self.bag = DisposeBag()
        self.cachedCellSizes = [:]
        self.refreshControl = UIRefreshControl()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.bag = DisposeBag()
        self.cachedCellSizes = [:]
        self.refreshControl = UIRefreshControl()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        onViewDidLoad()
        setupViews()
        setupBinding()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.main.async {
            self.refreshControl.beginRefreshing()
            self.refreshControl.endRefreshing()
        }
    }
    
    func onViewDidLoad() {
        pageViewModel?.viewDidLoad()
    }
    
    func setupBinding() {
        self.initInputBinding()
        self.initOutputBinding()
    }
    
    func setupViews() {
        self.view.backgroundColor = .white
    }
    
    func initInputBinding() {
        refreshControl.rx
            .controlEvent(.valueChanged)
            .sample(pageViewModel.pageInput.isDragging.asObservable())
            .do(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.pageViewModel.onRefresh()
                self.setNetworkIndicator(true)
            }).bind(to: pageViewModel.pageInput.loadPageTrigger)
            .disposed(by: bag)
    }
    
    func initOutputBinding() {
        pageViewModel.pageOutput
            .isPageLoading
            .drive(onNext: { [weak self] (isPageLoading) in
                guard let `self` = self else { return }
                isPageLoading ? self.startIndicators() : self.stopIndicators()
            }).disposed(by: bag)
        
        pageViewModel.pageOutput
            .isNextPageLoading
            .drive(onNext: { [weak self] (isNextPageLoading) in
                guard let `self` = self else { return }
                isNextPageLoading ? self.showNextPageIndicator() : self.hideNextPageIndicator()
            }).disposed(by: bag)
        
        pageViewModel.pageOutput
            .state
            .observeOn(mainScheduler)
            .subscribe(onNext: { [weak self] (state) in
                guard let `self` = self else { return }
                self.handleState(state)
            }).disposed(by: bag)
    }
    
    func reloadData() {
        pageViewModel.reloadData()
    }
    
    func endRefreshing() {
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
            setNetworkIndicator(false)
        }
    }
    
    func startIndicators() {
        if !refreshControl.isRefreshing {
            if !loadingIndicator.isAnimating {
                loadingIndicator.startAnimating()
                setNetworkIndicator(true)
            }
            setBackgroundView(loadingIndicator)
        }
    }
    
    func stopIndicators() {
        endRefreshing()
        loadingIndicator.stopAnimating()
        pageIndicator.stopAnimating()
        setNetworkIndicator(false)
    }
    
    func showNextPageIndicator() {
        pageIndicator.startAnimating()
        setNetworkIndicator(true)
    }
    
    func hideNextPageIndicator() {
        pageIndicator.stopAnimating()
        setNetworkIndicator(false)
    }
    
    func setNetworkIndicator(_ isVisible: Bool) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = isVisible
    }
    
    func willBeginDragging() {}
    
    func willEndDragging() {}
    
    func setBackgroundView(_ backgroundView: UIView?) {}
    
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
        return
    }
    
    func onLoaded() {
        setBackgroundView(nil)
    }
    
    func onError(_ err: ApiError) {
        self.stopIndicators()
    }

    func addKeyboardObservers() {
        let center = NotificationCenter.default
        center.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        
        center.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    
    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc
    func keyboardWillShow(_ notification: Notification) {
        guard
            let payload = notification.userInfo,
            var frame = (payload[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            else { return }
        
        frame.size.height -= view.windowSafeAreaInsets.bottom
        onKeyboardShow(keyboardFrame: frame)
    }
    
    @objc
    func keyboardWillHide(_ notification: Notification) {
        onKeyboardHide()
    }
    
    func onKeyboardShow(keyboardFrame: CGRect) {}
    
    func onKeyboardHide() {}
}
