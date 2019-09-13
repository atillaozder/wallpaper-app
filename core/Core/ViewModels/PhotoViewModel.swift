//
//  PhotoViewModel.swift
//  Core
//
//  Created by Atilla Özder on 10.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import class UIKit.UIImage
import SDWebImage
import RxSwift
import RxCocoa
import Photos

extension Bundle {
    var displayName: String {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "Free Wallpapers HD-4K"
    }
}

class PhotoViewModel {
    
    static let albumName = Bundle.main.displayName
    
    var item: Image
    var image: BehaviorRelay<UIImage?>
    var downloadedImage: UIImage? {
        willSet {
            image.accept(newValue)
        }
    }
    
    init(image: Image?) {
        self.item = image ?? Image()
        self.image = BehaviorRelay(value: nil)
        self.loadImage()
    }
    
    func loadImage() {
        let manager = SDWebImageManager.shared
        manager.loadImage(with: item.image?.asURL(), options: [], progress: nil)
        { [weak self] (image, _, _, _, _, _) in
            guard let `self` = self else { return }
            self.downloadedImage = image
        }
    }
    
    func toggleFavorite() {
        InterstitialHandler.shared().increase()
        StorageHelper.shared().toggleFavorite(for: item)
    }
    
    private func createAlbum(completion: @escaping (PHAssetCollection?)->()) {
        var albumPlaceholder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: PhotoViewModel.albumName)
            albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
        }, completionHandler: { success, error in
            if success {
                guard let placeholder = albumPlaceholder else {
                    completion(nil)
                    return
                }
                
                let fetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
                
                guard let album = fetchResult.firstObject else {
                    completion(nil)
                    return
                }
                
                completion(album)
            } else {
                completion(nil)
            }
        })
    }
    
    private func fetchAlbum() -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", PhotoViewModel.albumName)
        let fetchResult: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        guard let photoAlbum = fetchResult.firstObject else { return nil }
        return photoAlbum
    }
    
    func save(_ completion: ((Bool, Error?) -> Void)?) {        
        if let album = fetchAlbum() {
            saveImage(to: album, completion: completion)
        } else {
            createAlbum { [weak self] (collection) in
                guard
                    let `self` = self,
                    let album = collection
                else {
                    completion?(false, nil)
                    return
                }
                
                self.saveImage(to: album, completion: completion)
            }
        }
    }
    
    private func saveImage(to album: PHAssetCollection, completion: ((Bool, Error?) -> Void)?) {
        guard let image = self.downloadedImage else {
            completion?(false, nil)
            return
        }
        
        var placeholder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            let createAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            guard
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: album),
                let photoPlaceholder = createAssetRequest.placeholderForCreatedAsset
            else { return }
            
            placeholder = photoPlaceholder
            let fastEnumeration = NSArray(array: [photoPlaceholder] as [PHObjectPlaceholder])
            albumChangeRequest.addAssets(fastEnumeration)
            
        }, completionHandler: { success, error in
            guard let _ = placeholder else {
                completion?(false, nil)
                return
            }
            completion?(success, error)
        })
    }
}
