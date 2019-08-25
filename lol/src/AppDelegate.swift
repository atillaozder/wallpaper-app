//
//  AppDelegate.swift
//  Wallpapers for League of Legends
//
//  Created by Atilla Özder on 11.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import UIKit
import Core

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseHandler.initialize()
        setupNavigationBar()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.rootViewController = TabBarController()
        window?.makeKeyAndVisible()
        
        #if DEBUG
        if #available(iOS 11.0, *) {
            DroppingFramesHelper().activate()
        }
        #endif
        
        return true
    }
    
    private func setupNavigationBar() {
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().tintColor = .defaultTextColor
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.defaultTextColor]
    }
    
}
