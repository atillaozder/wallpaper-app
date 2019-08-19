//
//  CategoryPageController.swift
//  Core
//
//  Created by Atilla Özder on 4.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import UIKit

class CategoryPageController: PageController {
    
    weak var delegate: PageControllerDelegate?
    
    override func loadCollectionView() -> UICollectionView {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.headerReferenceSize = .zero
        flowLayout.footerReferenceSize = .zero
        flowLayout.minimumLineSpacing = UIConstants.kImageLineSpacing
        flowLayout.minimumInteritemSpacing = UIConstants.kImageInterItemSpacing
        flowLayout.sectionInset = UIConstants.kImageEdgeInsets
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        cv.backgroundColor = .white
        cv.showsHorizontalScrollIndicator = false
        cv.registerCell(LandImageCell.self)
        return cv
    }
    
    override func setDataSource() {
        viewModel.pageOutput
            .dataSource
            .drive(collectionView.rx.items(
                cellIdentifier: LandImageCell.identifier,
                cellType: LandImageCell.self))
            { (index, viewModel, cell) in
                cell.bind(to: viewModel)
            }.disposed(by: bag)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CategoryCellViewModel.imageTransformer.size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cvm = viewModel.cellViewModel(at: indexPath.item) else { return }
        delegate?.pageController(self, didSelectItem: .category(viewModel: cvm as! CategoryCellViewModel))
    }
}
