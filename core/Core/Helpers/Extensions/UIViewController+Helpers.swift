//
//  UIViewController+Helpers.swift
//  Core
//
//  Created by Atilla Özder on 10.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import UIKit
import GoogleMobileAds

extension UIViewController {
    func getBannerView() -> GADBannerView {
        let v = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        do {
            let appPList = try PListFile<InfoPList>()
            v.adUnitID = appPList.data.configuration.bannerUnitID
        } catch let err {
            #if DEBUG
            print("Failed to parse data: \(err.localizedDescription)")
            #endif
        }
        v.rootViewController = self
        v.load(GADRequest())
        return v
    }
}

extension UIViewController {
    
    static var toastIdentifier: Int = 999
    
    func showToast(with message: String, additionalInset: CGFloat = 0) {
        if let container = view.viewWithTag(UIViewController.toastIdentifier) {
            container.removeFromSuperview()
            self.view.addSubview(container)
            animateToast(container)
        } else {
            let height: CGFloat = 45
            
            let container = UIView()
            container.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            container.alpha = 0.0
            container.layer.cornerRadius = height / 2
            container.clipsToBounds = true
            container.tag = UIViewController.toastIdentifier
            
            let lbl = UILabel()
            lbl.textColor = .white
            lbl.font = UIFont.systemFont(ofSize: 16)
            lbl.textAlignment = .center
            lbl.text = message
            
            container.addSubview(lbl)
            lbl.pinEdgesToSuperview(insets: .init(top: 8, left: 16, bottom: -8, right: -16))
            
            self.view.addSubview(container)
            container.pinHeight(to: height)
            container.pinCenterX(to: view.centerXAnchor)
            
            let inset = additionalInset + view.windowSafeAreaInsets.bottom + 16
            container.pinBottom(to: view.bottomAnchor, constant: -inset)
            animateToast(container)
        }
    }
    
    private func animateToast(_ container: UIView) {
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: {
            container.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
                container.alpha = 0.0
            }, completion: { _ in
                container.removeFromSuperview()
            })
        })
    }
}
