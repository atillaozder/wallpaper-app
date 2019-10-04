//
//  Asset.swift
//  Core
//
//  Created by Atilla Özder on 17.09.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//


enum Asset: String {
    case icMenu = "ic_menu"
    case icDownload = "ic_download"
    case icUpload = "ic_upload"
    case icEdit = "ic_edit"
    case icEmptyStar = "ic_empty_star"
    case icFilledStar = "ic_filled_star"
    case icPreview = "ic_preview"
    case icLogo = "ic_logo"
    case icHeart = "ic_heart"
    case icMoreApp = "ic_more_app"
    case icPrivacyPolicy = "ic_privacy_policy"
    case icRecent = "ic_recent"
    case icCategory = "ic_category"
    case icRandom = "ic_random"
    
    var image: UIImage {
        return UIImage(asset: self)
    }
}

extension UIImage {
    convenience init(asset: Asset) {
        self.init(imageLiteralResourceName: asset.rawValue)
    }
}
