//
//  DetailViewModel.swift
//  Core
//
//  Created by Atilla Özder on 10.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import SDWebImage
import RxSwift
import RxCocoa
import Photos

class DetailViewModel {
    
    static let albumName = Bundle.main.displayName
    
    var dataSource: [ImageCellViewModel]
    var didReceiveAd: Bool
    var indexPath: IndexPath
    
    var navigationItemTitle: String {
        return "\(indexPath.item + 1) / \(dataSource.count)"
    }

    init(images: [ImageCellViewModel], startFrom index: Int) {
        self.indexPath = IndexPath(item: index, section: 0)
        self.didReceiveAd = false
        self.dataSource = images
    }
    
    func image() -> Image {
        return cellViewModel(at: indexPath).item
    }
        
    func uiImage() -> UIImage? {
        return cellViewModel(at: indexPath).downloadedImage
    }
        
    func cellViewModel(at indexPath: IndexPath) -> ImageCellViewModel {
        return dataSource[indexPath.item]
    }
    
    func toggleFavorite() {
        InterstitialHandler.shared().increase()
        StorageHelper.shared().toggleFavorite(for: image())
    }
    
    func setImage(_ image: UIImage) {
        cellViewModel(at: indexPath).setImage(image)
    }
    
    private func createAlbum(completion: @escaping (PHAssetCollection?)->()) {
        var albumPlaceholder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: DetailViewModel.albumName)
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
        fetchOptions.predicate = NSPredicate(format: "title = %@", DetailViewModel.albumName)
        let fetchResult: PHFetchResult = PHAssetCollection.fetchAssetCollections(
            with: .album,
            subtype: .any,
            options: fetchOptions)
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
    
    private func saveImage(to album: PHAssetCollection,
                           completion: ((Bool, Error?) -> Void)?) {
        guard let image = self.uiImage() else {
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
