//
//  HomePagerViewController.swift
//  Core
//
//  Created by Atilla Özder on 16.09.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import SideMenu

public class HomePagerViewController: PagerViewController {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = Bundle.main.displayName
        dataSource = self
        
        let barButton = UIBarButtonItem(
            image: Asset.icMenu.image,
            style: .plain,
            target: self,
            action: #selector(openSideMenu))
        self.navigationItem.setLeftBarButton(barButton, animated: false)
        let _ = SideMenuManager.default.addPanGestureToPresent(toView: self.navigationController!.navigationBar)
    }
    
    @objc
    func openSideMenu() {
        let settings = SideMenuSettings { (sms) in
            sms.statusBarEndAlpha = 0
            sms.presentationStyle = .viewSlideOutMenuIn
            sms.menuWidth = UIConstants.kSideMenuWidth
        }
        
        let sideMenu = SideMenuNavigationController(
            rootViewController: SideMenuViewController(),
            settings: settings)
        sideMenu.leftSide = true
        self.present(sideMenu, animated: true, completion: nil)
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
