//
//  UIImage+Crop.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import UIKit

extension UIImage {
    func crop(to newSize: CGSize) -> UIImage? {
        if newSize.width > newSize.height {
            return self.cropToLandscape(newSize)
        } else if newSize.width < newSize.height {
            return self.cropToPortrait(newSize)
        } else {
            return self.cropToSquare()
        }
    }
    
    func crop(bounds: CGRect) -> UIImage? {
        if let cgImage = self.cgImage?.cropping(to: bounds) {
            return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        }
        return nil
    }
    
    func cropToSquare() -> UIImage? {
        let newSize = CGSize(width: self.size.width * scale, height: self.size.height * scale)
        let shortest = min(newSize.width, newSize.height)
        let dx: CGFloat = (newSize.width > shortest) ? (newSize.width - shortest) / 2 : 0
        let dy: CGFloat = (newSize.height > shortest) ? (newSize.height - shortest) / 2 : 0
        let rect = CGRect(origin: .zero, size: newSize).insetBy(dx: dx, dy: dy)
        return crop(bounds: rect)
    }
    
    func cropToPortrait(_ newSize: CGSize) -> UIImage? {
        let ratio: CGFloat = newSize.width / newSize.height
        let cropWidth = self.size.height * ratio
        let newSize = CGSize(width: cropWidth * scale, height: self.size.height * scale)
        let pos = CGPoint(x: (self.size.width - cropWidth) / 2, y: 0)
        return crop(bounds: .init(origin: pos, size: newSize))
    }
    
    func cropToLandscape(_ newSize: CGSize) -> UIImage? {
        let ratio: CGFloat = newSize.width / newSize.height
        let cropHeight = self.size.width / ratio
        let newSize = CGSize(width: self.size.width * scale, height: cropHeight * scale)
        let pos = CGPoint(x: 0, y: (self.size.height - cropHeight) / 2)
        return crop(bounds: .init(origin: pos, size: newSize))
    }
}
