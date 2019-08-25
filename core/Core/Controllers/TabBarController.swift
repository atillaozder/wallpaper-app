//
//  TabBarController.swift
//  Core
//
//  Created by Atilla Özder on 25.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import UIKit

public class TabBarController: UITabBarController {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex = 0
        tabBar.unselectedItemTintColor = UIColor.gray
        tabBar.tintColor = .defaultTextColor
        tabBar.isTranslucent = false
        setupControllers()
    }
    
    private func setupControllers() {
        let tabBarItems: [UITabBarItem.SystemItem] = [.mostRecent, .favorites]
        let controllers = [HomeViewController(), FavoriteItemsViewController()]
        controllers.enumerated().forEach {
            $0.element.tabBarItem = .init(tabBarSystemItem: tabBarItems[$0.offset],
                                          tag: $0.offset)
        }
        
        self.viewControllers = controllers
            .map { NavigationController(rootViewController: $0) }
    }
    
}
