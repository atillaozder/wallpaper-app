//
//  NavigationController.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import UIKit

 class NavigationController: UINavigationController {
    
    var lastViewController: UIViewController?
    
     override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
     override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        viewController.navigationItem.backBarButtonItem = UIBarButtonItem()
        viewController.navigationItem.backBarButtonItem?.title = ""
        lastViewController = viewController
        super.pushViewController(viewController, animated: animated)
        setNavigationBar(visibleViewController: lastViewController)
    }
    
     override func popViewController(animated: Bool) -> UIViewController? {
        lastViewController = super.popViewController(animated: animated)
        setNavigationBar(visibleViewController: visibleViewController)
        return lastViewController
    }
    
     override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        let rootViewController = super.popToRootViewController(animated: animated)
        setNavigationBar(visibleViewController: visibleViewController)
        return rootViewController
    }
    
    func setNavigationBar(visibleViewController viewController: UIViewController?) {
        if let viewController = viewController,
            viewController.isKind(of: HomeViewController.self) {
            let img = UIImage()
            navigationBar.shadowImage = img
            navigationBar.setBackgroundImage(img, for: .default)
        } else {
            navigationBar.shadowImage = nil
            navigationBar.setBackgroundImage(nil, for: .default)
        }
    }
}

extension NavigationController: UINavigationControllerDelegate {
     func navigationController(_ navigationController: UINavigationController,
                                     willShow viewController: UIViewController,
                                     animated: Bool) {
        if let coordinator = navigationController.topViewController?.transitionCoordinator {
            coordinator.notifyWhenInteractionChanges { [weak self] (context) in
                guard let `self` = self else { return }
                if context.isCancelled {
                    self.setNavigationBar(visibleViewController: self.lastViewController)
                }
            }
        }
    }
}

