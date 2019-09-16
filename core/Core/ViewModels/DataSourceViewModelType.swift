//
//  DataSourceViewModelType.swift
//  Core
//
//  Created by Atilla Özder on 16.09.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation

enum DataSourceDisplayType {
    case row, item
}

protocol DataSourceViewModelType {
    func cellViewModel(at index: Int) -> Identifiable?
    func willDisplayCell(for type: DataSourceDisplayType, at indexPath: IndexPath)
    func didEndDisplayingCell(for type: DataSourceDisplayType, at indexPath: IndexPath)
    func prefetch(for type: DataSourceDisplayType, at indexPaths: [IndexPath])
    func cancelPrefetching(for type: DataSourceDisplayType, at indexPaths: [IndexPath])
}

extension DataSourceViewModelType {
    private func getIdx(for type: DataSourceDisplayType, indexPath: IndexPath) -> Int {
        let tableIdx = indexPath.row == 0 ? indexPath.section : indexPath.row
        return type == .row ? tableIdx : indexPath.item
    }
    
    func willDisplayCell(for type: DataSourceDisplayType, at indexPath: IndexPath) {
        let idx = getIdx(for: type, indexPath: indexPath)
        guard let cvm = cellViewModel(at: idx) as? ImageFetchable else { return }
        cvm.fetchImages()
    }
    
    func didEndDisplayingCell(for type: DataSourceDisplayType, at indexPath: IndexPath) {
        let idx = getIdx(for: type, indexPath: indexPath)
        if let cvm = cellViewModel(at: idx) as? ImageFetchable {
            cvm.cancelFetching()
        }
    }
    
    func prefetch(for type: DataSourceDisplayType, at indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let idx = getIdx(for: type, indexPath: indexPath)
            if let cvm = cellViewModel(at: idx) as? ImageFetchable {
                cvm.fetchImages()
            }
        }
    }
    
    func cancelPrefetching(for type: DataSourceDisplayType, at indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let idx = getIdx(for: type, indexPath: indexPath)
            if let cvm = cellViewModel(at: idx) as? ImageFetchable {
                cvm.cancelFetching()
            }
        }
    }
}
