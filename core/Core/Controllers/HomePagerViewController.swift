//
//  HomePagerViewController.swift
//  Core
//
//  Created by Atilla Özder on 16.09.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import SideMenu

public class HomePagerViewController: PagerViewController {
    
    private var askedForReview: Bool = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = Bundle.main.displayName
        dataSource = self
        
        let barButton = UIBarButtonItem(
            image: Asset.icMenu.image.withRenderingMode(.alwaysTemplate),
            style: .plain,
            target: self,
            action: #selector(openSideMenu))
        barButton.tintColor = .white
        self.navigationItem.setLeftBarButton(barButton, animated: false)
        let _ = SideMenuManager.default.addPanGestureToPresent(toView: self.navigationController!.navigationBar)
        
        registerRemoteNotifications()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !askedForReview {
            StoreReviewHelper().askForReview()
            askedForReview = true
        }
    }
    
    private func registerRemoteNotifications() {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current()
            .requestAuthorization(options: options) { (_, _) in
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
        }
    }
    
    @objc
    func openSideMenu() {
        let settings = SideMenuSettings { (sms) in
            sms.statusBarEndAlpha = 0
            sms.presentationStyle = .viewSlideOutMenuIn
            sms.menuWidth = UIConstants.kSideMenuWidth
        }
        
        let rootViewController = SideMenuViewController()
        let sideMenu = SideMenuNavigationController(
            rootViewController: rootViewController,
            settings: settings)
        
        rootViewController.delegate = self
        sideMenu.leftSide = true
        self.present(sideMenu, animated: true, completion: nil)
    }
}

extension HomePagerViewController: SideMenuViewControllerDelegate {
    func sideMenuViewController(_ viewController: SideMenuViewController,
                                didSelectPageMenu pageMenu: HomePageMenu) {
        self.move(at: pageMenu.rawValue, animated: false)
    }
}

extension HomePagerViewController: PagerViewControllerDataSource {
    public func pagerViewController(
        viewControllersIn pagerViewController: PagerViewController) -> [UIViewController] {
        return [
            ImageListViewController(),
            CategoriesViewController(),
            ImageListViewController(),
            FavoritesViewController(viewModel: FavoritesViewModel())
        ]
    }
    
    public func pagerViewController(_ pagerViewController: PagerViewController,
                                    titlesFor menuBar: MenuBar) -> [String] {
        return [
            Localization.recent,
            Localization.category,
            Localization.random,
            Localization.favorites
        ]
    }
    
    public func pagerViewController(_ pagerViewController: PagerViewController,
                                    heightFor menuBar: MenuBar) -> CGFloat {
        return MenuBar.defaultBarHeight
    }
}
