//
//  ImageCellViewModel.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import RxCocoa
import SDWebImage

class ImageCellViewModel: Identifiable, ImageFetchable {
    
    var item: Image
    var imageUrl: URL? {
        return item.image?.asURL()
    }
    
    var image: BehaviorRelay<UIImage?>
    var downloadedImage: UIImage? {
        willSet {
            image.accept(newValue)
        }
    }
    
    var portraitImagePrefetcher: ImagePrefetcher
    var prefetchers: [ImagePrefetcher]
    
    class var imageTransformer: ImageTransformer {
        return ImageTransformer(size: UIConstants.kItemSize,
                                fillColor: .imageBackground,
                                contentMode: .scaleToFill)
    }
    
    var identifier: String {
        return "\(item.id)"
    }
            
    init(item: Image) {
        self.item = item
        self.portraitImagePrefetcher = ImagePrefetcher(
            url: item.image?.asURL(),
            transformer: ImageCellViewModel.imageTransformer)
        self.prefetchers = [portraitImagePrefetcher]
        self.image = BehaviorRelay(value: nil)
    }
    
    func set(_ object: Identifiable) {
        guard let cvm = object as? ImageCellViewModel else { return }
        self.portraitImagePrefetcher = cvm.portraitImagePrefetcher
    }
    
    func loadImage() {
        if downloadedImage == nil {
            let manager = SDWebImageManager.shared
            manager.loadImage(with: item.image?.asURL(), options: [], progress: nil)
            { [weak self] (image, _, _, _, _, _) in
                guard let `self` = self else { return }
                self.downloadedImage = image
            }
        }
    }
    
    func setImage(_ image: UIImage) {
        self.downloadedImage = image
    }
}
