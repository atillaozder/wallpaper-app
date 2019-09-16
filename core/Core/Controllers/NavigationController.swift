//
//  NavigationController.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

protocol NavigationBarSettable {
    var isTranslucent: Bool { get }
}

extension NavigationBarSettable {
    var isTranslucent: Bool {
        return true
    }
}

public class NavigationController: UINavigationController {
    
    private lazy var popGestureRecognizer = InteractivePopGestureRecognizer(controller: self)
    private(set) var lastViewController: UIViewController?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        interactivePopGestureRecognizer?.delegate = popGestureRecognizer
    }
    
    public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        viewController.navigationItem.backBarButtonItem = UIBarButtonItem()
        viewController.navigationItem.backBarButtonItem?.title = ""
        lastViewController = viewController
        super.pushViewController(viewController, animated: animated)
        setNavigationBar(visibleViewController: lastViewController)
    }
    
    public override func popViewController(animated: Bool) -> UIViewController? {
        lastViewController = super.popViewController(animated: animated)
        setNavigationBar(visibleViewController: visibleViewController)
        return lastViewController
    }
    
    public override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        let rootViewController = super.popToRootViewController(animated: animated)
        setNavigationBar(visibleViewController: visibleViewController)
        return rootViewController
    }
    
    func setNavigationBar(visibleViewController viewController: UIViewController?) {
        if let navBar = viewController as? NavigationBarSettable {
            navigationBar.isTranslucent = navBar.isTranslucent
            setSeparatorLine(true)
        } else {
            navigationBar.isTranslucent = false
            setSeparatorLine(false)
        }
    }
    
    func setSeparatorLine(_ isHidden: Bool) {
        if isHidden {
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
    public func navigationController(_ navigationController: UINavigationController,
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

