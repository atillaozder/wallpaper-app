//
//  UIImage+Resizable.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import CoreGraphics

extension UIImage {
    
    func resize(from transformer: ImageTransformer) -> UIImage? {
        return resize(
            to: transformer.size,
            with: transformer.cornerRadius,
            fillColor: transformer.fillColor,
            borderWidth: transformer.borderWidth,
            borderColor: transformer.borderColor,
            isOpaque: transformer.isOpaque,
            alpha: transformer.alpha)
    }
    
    func resize(to newSize: CGSize,
                with radius: CGFloat,
                fillColor: UIColor = .white,
                borderWidth: CGFloat? = nil,
                borderColor: UIColor = .defaultBorder,
                isOpaque: Bool = true,
                alpha: CGFloat? = nil) -> UIImage?
    {
        let scale: CGFloat = UIScreen.main.scale
        let rect = CGRect(origin: .zero, size: newSize)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, isOpaque, scale)
        defer { UIGraphicsEndImageContext() }
        
        guard let ctx = UIGraphicsGetCurrentContext() else { return self }
        
        let path = UIBezierPath(roundedRect: rect, cornerRadius: radius)
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        
        ctx.saveGState()
        
        // to prevent black background
        if isOpaque {
            ctx.setFillColor(fillColor.cgColor)
            ctx.fill(rect)
        }
        
        path.addClip()
        path.close()
        
        fillColor.setFill()
        path.fill()
        
        self.draw(in: rect)
        
        if let border = borderWidth {
            path.lineWidth = border
            borderColor.setStroke()
            path.stroke()
        }
        
        if let iAlpha = alpha {
            let color = UIColor.black.withAlphaComponent(iAlpha)
            ctx.setFillColor(color.cgColor)
            ctx.fill(rect)
        }
        
        ctx.restoreGState()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image ?? self
    }
    
    func resize(to newSize: CGSize,
                fillColor: UIColor = .white,
                tintColor: UIColor? = nil) -> UIImage
    {
        let rect = CGRect(origin: .zero, size: newSize)
        
        var alpha: CGFloat = 0
        fillColor.getRed(nil, green: nil, blue: nil, alpha: &alpha)
        let isOpaque = (alpha == 1.0 && tintColor != nil)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, isOpaque, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        guard let ctx = UIGraphicsGetCurrentContext() else { return self }
        
        ctx.saveGState()
        
        if isOpaque {
            ctx.setBlendMode(.normal)
            ctx.setFillColor(fillColor.cgColor)
            ctx.fill(rect)
        }
        
        if let tintColor = tintColor {
            ctx.setBlendMode(.destinationIn)
            ctx.setFillColor(tintColor.cgColor)
            ctx.fill(rect)
        }
        
        self.draw(in: rect)
        
        ctx.restoreGState()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image ?? self
    }
}
