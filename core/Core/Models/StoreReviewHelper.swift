//
//  StoreReviewHelper.swift
//  Core
//
//  Created by Atilla Özder on 4.10.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation
import StoreKit

public struct StoreReviewHelper {
    
    private let APP_OPENED_COUNT = "app_opened_count"

    public init() {}
    
    private func incrementAppOpenedCount() {
        let defaults = UserDefaults.standard
        guard var appOpenCount = defaults.value(forKey: APP_OPENED_COUNT) as? Int else {
            defaults.set(1, forKey: APP_OPENED_COUNT)
            return
        }
        appOpenCount += 1
        defaults.set(appOpenCount, forKey: APP_OPENED_COUNT)
    }
    
    public func askForReview() {
        incrementAppOpenedCount()
        
        let defaults = UserDefaults.standard
        guard let appOpenCount = defaults.value(forKey: APP_OPENED_COUNT) as? Int else {
            defaults.set(1, forKey: APP_OPENED_COUNT)
            return
        }
        
        switch appOpenCount {
        case 10, 50:
            StoreReviewHelper().requestReview()
        case _ where appOpenCount % 100 == 0 :
            StoreReviewHelper().requestReview()
        default:
            break
        }
    }
    
    func requestReview() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }
    }
}
