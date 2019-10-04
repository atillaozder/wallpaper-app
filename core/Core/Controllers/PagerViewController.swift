//
//  PagerViewController.swift
//  Core
//
//  Created by Atilla Özder on 16.09.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

public protocol PagerViewControllerDataSource: class {
    func pagerViewController(
        viewControllersIn pagerViewController: PagerViewController) -> [UIViewController]
    func pagerViewController(_ pagerViewController: PagerViewController,
                             titlesFor menuBar: MenuBar) -> [String]
    func pagerViewController(_ pagerViewController: PagerViewController,
                             heightFor menuBar: MenuBar) -> CGFloat
}

extension PagerViewControllerDataSource {
    public func pagerViewController(_ pagerViewController: PagerViewController,
                             heightFor menuBar: MenuBar) -> CGFloat {
        return MenuBar.defaultBarHeight
    }
}

public class PagerViewController: UIViewController {
    
    var isTranslucent: Bool {
        return false
    }
    
    var viewControllers: [UIViewController] = [] {
        didSet {
            if !viewControllers.isEmpty {
                self.loadFirstController()
            }
        }
    }
    
    weak var dataSource: PagerViewControllerDataSource? {
        didSet {
            if let ds = dataSource {
                self.viewControllers = ds.pagerViewController(viewControllersIn: self)
                self.menuBar.titles = ds.pagerViewController(self, titlesFor: menuBar)
                let height = ds.pagerViewController(self, heightFor: menuBar)
                self.menuBar.pinHeight(to: height)
            }
        }
    }
    
    lazy var menuBar: MenuBar = {
        let mb = MenuBar()
        mb.delegate = self
        return mb
    }()
    
    lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.isPagingEnabled = true
        sv.bounces = true
        sv.alwaysBounceHorizontal = true
        sv.alwaysBounceVertical = false
        sv.scrollsToTop = false
        sv.delegate = self
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            sv.contentInsetAdjustmentBehavior = .never
        }
        return sv
    }()
    
    private var lastSize = CGSize(width: 0, height: 0)
    var currentIndex: Int
    
    public init(currentIndex: Int = 0) {
        self.currentIndex = currentIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.currentIndex = 0
        super.init(coder: aDecoder)
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateContentIfNeeded()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func loadFirstController() {
        self.menuBar.startIndex = currentIndex
        let childController = viewControllers[currentIndex]
        self.addChild(childController)
        childController.view.autoresizingMask = [.flexibleHeight]
        self.scrollView.addSubview(childController.view)
        childController.didMove(toParent: self)
    }
    
    public func setupViews() {
        view.backgroundColor = .darkTheme
        setupMenuBar()
        setupScrollView()
    }
    
    public func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.pinEdgesToView(view, exclude: [.top])
        scrollView.pinTop(to: menuBar.bottomAnchor)
    }
    
    public func setupMenuBar() {
        view.insertSubview(menuBar, at: 1)
        menuBar.pinEdgesToView(view, insets: .zero, exclude: [.top, .bottom])
        if #available(iOS 11.0, *) {
            menuBar.pinTop(to: view.safeTopAnchor)
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
            menuBar.pinTop(to: topLayoutGuide.bottomAnchor)
        }
    }
    
    public func move(to viewController: UIViewController?, animated: Bool = true) {
        guard
            let controller = viewController,
            let index = viewControllers.firstIndex(of: controller)
            else { return }
        self.move(at: index, animated: animated)
    }
    
    public func move(at index: Int, animated: Bool = true) {
        self.menuBar.scroll(at: index, animated: animated)
        self.scrollView.setContentOffset(.init(x: pageOffsetForChild(at: index), y: 0), animated: animated)
    }
    
    public func visibleViewController() -> UIViewController? {
        if currentIndex < viewControllers.count {
            return viewControllers[currentIndex]
        }
        return nil
    }
    
    private func pageOffsetForChild(at index: Int) -> CGFloat {
        return CGFloat(index) * view.bounds.width
    }
    
    private func updateContentSize() {
        if scrollView.contentSize.height != scrollView.bounds.height {
            scrollView.contentSize = CGSize(
                width: view.bounds.width * CGFloat(viewControllers.count),
                height: scrollView.bounds.height)
        }
    }
    
    private func updateContentIfNeeded() {
        if isViewLoaded && !lastSize.equalTo(scrollView.bounds.size) {
            updateContent()
        }
    }
    
    private func updateContent() {
        if lastSize.width != scrollView.bounds.size.width {
            scrollView.contentOffset = CGPoint(x: pageOffsetForChild(at: currentIndex), y: 0)
        }
        
        lastSize = scrollView.bounds.size
        updateContentSize()
        
        for (index, childController) in viewControllers.enumerated() {
            let pageOffset = self.pageOffsetForChild(at: index)
            if abs(scrollView.contentOffset.x - pageOffset) < scrollView.bounds.width {
                let origin = CGPoint(x: pageOffset, y: 0)
                let size = CGSize(width: view.bounds.width, height: scrollView.bounds.height)
                
                if childController.parent != nil {
                    childController.view.frame = CGRect(origin: origin, size: size)
                    childController.view.autoresizingMask = [.flexibleHeight]
                } else {
                    childController.beginAppearanceTransition(true, animated: false)
                    addChild(childController)
                    childController.view.frame = CGRect(origin: origin, size: size)
                    childController.view.autoresizingMask = [.flexibleHeight]
                    scrollView.addSubview(childController.view)
                    childController.didMove(toParent: self)
                    childController.endAppearanceTransition()
                }
            } else {
                if childController.parent != nil {
                    childController.beginAppearanceTransition(false, animated: false)
                    childController.willMove(toParent: nil)
                    childController.view.removeFromSuperview()
                    childController.removeFromParent()
                    childController.endAppearanceTransition()
                }
            }
        }
        
        let idx = Int(round(scrollView.contentOffset.x / view.frame.width))
        currentIndex = min(idx, viewControllers.count - 1)
    }
}

extension PagerViewController: NavigationBarSettable {}

extension PagerViewController: MenuBarScrollDelegate {
    public func menuBar(_ menuBar: MenuBar, didSelectItemAt indexPath: IndexPath) {
        let pageOffset = pageOffsetForChild(at: indexPath.item)
        let contentOffset = CGPoint(x: pageOffset, y: scrollView.contentOffset.y)
        self.scrollView.setContentOffset(contentOffset, animated: true)
    }
}

extension PagerViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateContent()
        let indicatorOffset = scrollView.contentOffset.x / CGFloat(viewControllers.count)
        self.menuBar.updateIndicator(indicatorOffset)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageIndex = targetContentOffset.pointee.x / view.frame.width
        menuBar.scroll(at: Int(pageIndex))
    }
}
