//
//  ViewFactory.swift
//  Core
//
//  Created by Atilla Özder on 4.10.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import UIKit

public struct ViewFactory {
    
    public init() {}
    
    public func setupNavigationBar() {
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().barTintColor = .darkTheme
        
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UINavigationBar.appearance().titleTextAttributes = attributes
        if #available(iOS 11.0, *) {
            UINavigationBar.appearance().largeTitleTextAttributes = attributes
        }
    }
    
}
