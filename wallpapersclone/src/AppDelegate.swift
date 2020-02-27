//
//  AppDelegate.swift
//  CloneOne
//
//  Created by Atilla Özder on 12.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import UIKit
import Core

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        #warning("Needs a GoogleService-Info.plist file")
        // FirebaseHandler.initialize()
        ViewFactory().setupNavigationBar()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .darkTheme
        window?.rootViewController = NavigationController(rootViewController: HomePagerViewController())
        window?.makeKeyAndVisible()
        
        #if DEBUG
        if #available(iOS 11.0, *) {
            DroppingFramesHelper().activate()
        }
        #endif
        
        return true
    }
}
