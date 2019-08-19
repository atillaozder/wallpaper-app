//
//  PagedCollectionCell.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import UIKit
import RxSwift

enum CellViewModelType {
    case image(viewModel: ImageCellViewModel)
    case category(viewModel: CategoryCellViewModel)
}

protocol PageControllerDelegate: class {
    func pageController(_ pageController: PageController, didSelectItem item: CellViewModelType)
}

class PagedCollectionCell: CollectionCell {
    
    private(set) lazy var pageController: PageController = {
        return getPageController()
    }()
    
    unowned var collectionView: UICollectionView {
        return pageController.collectionView
    }
    
    var viewModel: PagedViewModelType {
        return pageController.viewModel
    }
    
    override func setup() {
        super.setup()
        setupViews()
    }
    
    func getPageController() -> PageController {
        return .init()
    }
    
    func setupViews() {
        contentView.backgroundColor = .white
        contentView.addSubview(collectionView)
        collectionView.pinEdgesToSuperview()
        pageController.setupViews()
    }
    
    func load() {
        pageController.load()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        collectionView.prefetchDataSource = nil
        collectionView.delegate = nil
        pageController.dispose()
    }
    
    func setDelegates(_ delegate: PageControllerDelegate?) {
        collectionView.delegate = pageController
        collectionView.prefetchDataSource = pageController
        pageController.bind()
    }
}
