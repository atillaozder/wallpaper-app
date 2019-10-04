//
//  ImageTransformer.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

let DEFAULT_CONTENT_MODE: UIView.ContentMode = .scaleAspectFill

class ImageTransformer {
    
    var size: CGSize
    var cornerRadius: CGFloat
    var fillColor: UIColor
    var borderColor: UIColor
    var borderWidth: CGFloat?
    var isOpaque: Bool
    var alpha: CGFloat?
    var contentMode: UIView.ContentMode
    
    enum TransformerMode {
        case circular
        case corners(radius: CGFloat)
    }
    
    var transformerKey: String {
        return "\(size.width), \(size.height) \(cornerRadius)"
    }
    
    init(size: CGSize,
         cornerRadius: TransformerMode = .corners(radius: 0),
         fillColor: UIColor = .white,
         borderColor: UIColor = .border,
         borderWidth: CGFloat? = nil,
         isOpaque: Bool = true,
         alpha: CGFloat? = nil,
         contentMode: UIView.ContentMode = DEFAULT_CONTENT_MODE)
    {
        
        self.size = size
        switch cornerRadius {
        case .circular:
            self.cornerRadius = size.width / 2
        case .corners(let radius):
            self.cornerRadius = radius
        }
        
        self.fillColor = fillColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.isOpaque = isOpaque
        self.alpha = alpha
        self.contentMode = contentMode
    }
    
    private func cropImage(_ image: UIImage) -> UIImage? {
        switch contentMode {
        case .scaleToFill:
            return image
        default:
            return image.crop(to: self.size)
        }
    }
    
    func transformedImage(with image: UIImage, forKey key: String = "") -> UIImage? {
        return cropImage(image)?.resize(from: self)
    }
}

