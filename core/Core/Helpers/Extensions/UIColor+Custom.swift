//
//  UIColor+Custom.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import UIKit

public extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(
            red: CGFloat(red) / 255,
            green: CGFloat(green) / 255,
            blue: CGFloat(blue) / 255,
            alpha: 1
        )
    }
    
    class var defaultImageBackground: UIColor {
        return .init(red: 211, green: 211, blue: 211)
    }
    
    class var defaultBorder: UIColor {
        return .init(red: 210, green: 210, blue: 210)
    }
    
    class var defaultTextColor: UIColor {
        return .init(red: 34, green: 34, blue: 34)
    }
    
    class var separator: UIColor {
        return .init(red: 224, green: 224, blue: 224)
    }
}
