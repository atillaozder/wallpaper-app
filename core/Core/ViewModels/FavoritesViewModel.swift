//
//  FavoritesViewModel.swift
//  Core
//
//  Created by Atilla Özder on 25.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation
import RxSwift

class FavoritesViewModel: ImageViewModel {
    
    override func getPageRequest() -> URLRequestConfigurable? {
        return nil
    }
    
    override func fetchData() -> Observable<[ImageCellViewModel]> {
        let dataSource = StorageHelper.shared()
            .favorites()
            .map { return ImageCellViewModel(item: $0) }
        return .just(dataSource)
    }
}
