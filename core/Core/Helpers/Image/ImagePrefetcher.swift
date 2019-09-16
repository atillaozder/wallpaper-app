//
//  ImagePrefetcher.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import RxSwift
import RxCocoa
import SDWebImage

class ImagePrefetcher {
    private let prefetchQueue: DispatchQueue
    private var imageSubject: PublishSubject<UIImage?>
    private(set) var image: UIImage?
    
    var imageObservable: Observable<UIImage?>
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
                label: "com.appraf.imageprefetcher",
                qos: .userInitiated
            )
        }
        
        self.imageSubject = PublishSubject()
        self.imageObservable = self.imageSubject.asObservable()
    }
    
    func fetch() {
        if image != nil {
            imageSubject.onNext(image)
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
                NSLog("ImagePrefetcher error \(err?.localizedDescription ?? "No error message is provided!")")
                #endif
                self.image = nil
                self.imageSubject.onNext(nil)
                self.loadOperation = nil
                return
            }
            
            self.prefetchQueue.async {
                if let img = image, let imageTransformer = self.transformer {
                    let resizedImage = imageTransformer.transformedImage(with: img, forKey: imageTransformer.transformerKey)
                    self.image = resizedImage
                    self.imageSubject.onNext(resizedImage)
                } else {
                    self.image = image
                    self.imageSubject.onNext(image)
                }
            }
        }
    }
    
    func reset() {
        self.image = nil
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

extension ImagePrefetcher: Equatable {
    static func == (lhs: ImagePrefetcher, rhs: ImagePrefetcher) -> Bool {
        return lhs.url == rhs.url
    }
}

extension SDWebImageOperation {
    func asOperation() -> Operation? {
        return self as? Operation
    }
}
