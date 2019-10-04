//
//  UIColor+Custom.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

public extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(
            red: CGFloat(red) / 255,
            green: CGFloat(green) / 255,
            blue: CGFloat(blue) / 255,
            alpha: 1
        )
    }
    
    class var imageBackground: UIColor {
        return .init(red: 211, green: 211, blue: 211)
    }
    
    class var border: UIColor {
        return .init(red: 210, green: 210, blue: 210)
    }
    
    class var textColor: UIColor {
        return .init(red: 34, green: 34, blue: 34)
    }
    
    class var separator: UIColor {
        return .init(red: 224, green: 224, blue: 224)
    }
    
    class var darkTheme: UIColor {
        return .init(red: 18, green: 18, blue: 18)
    }
}
