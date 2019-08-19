//
//  UIView+Utils.swift
//  Core
//
//  Created by Atilla Özder on 10.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import UIKit

extension UIView {
    func addTapGesture(_ target: AnyObject,
                       action: Selector?,
                       cancelTouches: Bool = true) {
        self.isUserInteractionEnabled = true
        let recognizer = UITapGestureRecognizer(target: target, action: action)
        recognizer.cancelsTouchesInView = cancelTouches
        self.addGestureRecognizer(recognizer)
    }
}
