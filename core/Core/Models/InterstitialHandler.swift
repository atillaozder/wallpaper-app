//
//  InterstitialHandler.swift
//  Core
//
//  Created by Atilla Özder on 10.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation
import Firebase
import GoogleMobileAds

public class FirebaseHandler {
    public static func initialize() {
        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
}

protocol InterstitialHandlerDelegate: class {
    func showInterstitialAd(_ handler: InterstitialHandler, interstitial: GADInterstitial)
}

class InterstitialHandler: NSObject {
    
    weak var delegate: InterstitialHandlerDelegate?
    private static let sharedInstance = InterstitialHandler()
    
    private var counter: Int
    var interstitial: GADInterstitial!
    
    override init() {
        self.counter = 0
        super.init()
        self.interstitial = loadInterstitial()
    }
    
    static func shared() -> InterstitialHandler {
        return InterstitialHandler.sharedInstance
    }
    
    func increase() {
        counter += 1
        if counter == 4 {
            if interstitial.isReady {
                delegate?.showInterstitialAd(self, interstitial: interstitial)
            }
            counter = 0
        }
    }
    
    func loadInterstitial() -> GADInterstitial {
        var adUnitID: String = ""
        do {
            let appPList = try PListFile<InfoPList>()
            adUnitID = appPList.data.configuration.interstitialUnitID
        } catch let err {
            #if DEBUG
            print("Failed to parse data: \(err.localizedDescription)")
            #endif
        }
        
        let v = GADInterstitial(adUnitID: adUnitID)
        v.delegate = self
        v.load(GADRequest())
        return v
    }
}

extension InterstitialHandler: GADInterstitialDelegate {
    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        self.interstitial = self.loadInterstitial()
    }
}
