//
//  UIImage+Resizable.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import UIKit
import CoreGraphics

extension UIImage {
    
    func resize(to newSize: CGSize,
                radius: CGFloat,
                fillColor: UIColor = .white,
                borderWidth: CGFloat? = nil,
                borderColor: UIColor = .defaultBorder,
                isOpaque: Bool = true,
                alpha: CGFloat? = nil) -> UIImage?
    {
        let scale: CGFloat = UIScreen.main.scale
        let rect = CGRect(origin: .zero, size: newSize)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, isOpaque, scale)
        let ctx = UIGraphicsGetCurrentContext()
        
        let path = UIBezierPath(roundedRect: rect, cornerRadius: radius)
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.close()
        
        // to prevent black background
        if isOpaque {
            ctx?.setFillColor(fillColor.cgColor)
            ctx?.fill(rect)
        }
        
        ctx?.saveGState()
        path.addClip()
        
        fillColor.setFill()
        path.fill()
        
        self.draw(in: rect)
        
        if let border = borderWidth {
            path.lineWidth = border
            borderColor.setStroke()
            path.stroke()
        }
        
        if let imageAlpha = alpha, let cgImage = self.cgImage {
            UIColor.black.withAlphaComponent(imageAlpha).setFill()
            ctx?.fill(rect)
            ctx?.setBlendMode(.destinationIn)
            ctx?.draw(cgImage, in: rect)
        }
        
        ctx?.restoreGState()
        
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resized ?? self
    }
    
    func resize(to size: CGSize,
                fillColor: UIColor = .white,
                tintColor: UIColor? = nil) -> UIImage
    {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = UIScreen.main.scale
        format.opaque = (fillColor == .white && tintColor != nil)
        
        return UIGraphicsImageRenderer(size: size, format: format).image { ctx in
            let rect = CGRect(origin: .zero, size: size)
            if let color = tintColor {
                fillColor.setFill()
                ctx.fill(rect, blendMode: .normal)
                color.setFill()
                ctx.fill(rect, blendMode: .destinationIn)
            }
            self.draw(in: rect)
        }
    }
}
