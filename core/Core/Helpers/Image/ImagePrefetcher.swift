//
//  ImagePrefetcher.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SDWebImage

class ImagePrefetcher {
    
    private let prefetchQueue: DispatchQueue
    private var imageSubject: PublishSubject<UIImage?>
    private(set) var cachedImage: UIImage?
    
    var image: Driver<UIImage?>
    var url: URL?
    var transformer: ImageTransformer?
    var loadOperation: SDWebImageCombinedOperation?
    
    init(url: URL?,
         transformer: ImageTransformer?,
         prefetchQueue: DispatchQueue? = nil)
    {
        self.url = url
        self.transformer = transformer
        
        if let queue = prefetchQueue {
            self.prefetchQueue = queue
        } else {
            self.prefetchQueue = DispatchQueue(
                label: "com.appraf.prefetcher",
                qos: .utility,
                attributes: .concurrent
            )
        }
        
        self.imageSubject = PublishSubject()
        self.image = self.imageSubject.asDriver(onErrorJustReturn: nil)
    }
    
    func fetch() {
        if cachedImage != nil {
            imageSubject.onNext(cachedImage)
            return
        }
        
        if url == nil || loadOperation != nil {
            return
        }
        
        let imageManager = SDWebImageManager.shared
        let context: [SDWebImageContextOption: Any] = [:]
        
        self.loadOperation = imageManager.loadImage(
            with: self.url,
            options: [.retryFailed],
            context: context,
            progress: nil)
        { [weak self] (image, data, err, _, _, _) in
            guard let `self` = self else { return }
            if err != nil {
                #if DEBUG
                NSLog("Error occupied while trying to load image \(err?.localizedDescription ?? "No error message is provided!")")
                #endif
                self.cachedImage = nil
                self.imageSubject.onNext(nil)
                self.loadOperation = nil
                return
            }
            
            self.prefetchQueue.async {
                if let img = image, let imageTransformer = self.transformer {
                    let resizedImage = imageTransformer.transformedImage(with: img, forKey: imageTransformer.transformerKey)
                    self.cachedImage = resizedImage
                    self.imageSubject.onNext(resizedImage)
                } else {
                    self.cachedImage = image
                    self.imageSubject.onNext(image)
                }
            }
        }
    }
    
    func reset() {
        self.cachedImage = nil
        self.loadOperation = nil
    }
    
    func cancel() {
        guard let op = self.loadOperation else {
            return
        }
        
        let isLoaded = op.loaderOperation?.asOperation()?.isFinished ?? false
        let isCached = op.cacheOperation?.asOperation()?.isFinished ?? false
        
        if isLoaded && isCached {
            return
        } else if isCached {
            return
        } else {
            op.cancel()
            loadOperation = nil
        }
    }
}

extension SDWebImageOperation {
    func asOperation() -> Operation? {
        return self as? Operation
    }
}

