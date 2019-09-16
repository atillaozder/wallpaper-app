//
//  InteractivePopGestureRecognizer.swift
//  Core
//
//  Created by Atilla Özder on 16.09.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation
class InteractivePopGestureRecognizer: NSObject {
    
    weak var navigationController: UINavigationController?
    
    init(controller: UINavigationController) {
        self.navigationController = controller
    }
}

extension InteractivePopGestureRecognizer: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let navController = navigationController else { return false }
        return navController.viewControllers.count > 1
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
