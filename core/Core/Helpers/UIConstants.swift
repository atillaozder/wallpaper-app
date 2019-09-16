//
//  UIConstants.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

extension CGFloat {
    func asSize() -> CGSize {
        return .init(width: self, height: self)
    }
    
    func roundNearest(_ toNearest: CGFloat) -> CGFloat {
        return (self / toNearest).rounded() * toNearest
    }
}

struct UIConstants {
    private static var kItemInOneLine: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 5
        } else {
            return 3
        }
    }
    
    static let kNextPageIndicatorHeight: CGFloat = 80
    static let kSideMenuWidth: CGFloat = 250
    static let kImageOffset: CGFloat = 1
    static let kImageInterItemSpacing: CGFloat = 1
    static let kImageLineSpacing: CGFloat = 1
    static let kItemSize: CGSize = .init(width: UIConstants.itemWidth(), height: UIConstants.itemHeight())
    static let kImageEdgeInsets: UIEdgeInsets = .init(top: UIConstants.kImageOffset * 2, left: UIConstants.kImageOffset, bottom: UIConstants.kImageOffset, right: UIConstants.kImageOffset)
    
    static func itemHeight() -> CGFloat {
        return (UIConstants.itemWidth() * 3 / 2).rounded()
    }
    
    static func itemWidth() -> CGFloat {
        var itemWidth = UIScreen.main.bounds.width - (UIConstants.kImageOffset * 2)
        itemWidth -= ((UIConstants.kItemInOneLine - 1) * UIConstants.kImageInterItemSpacing)
        return (itemWidth / UIConstants.kItemInOneLine).rounded(.down)
    }
}
