//
//  LandImageCellView.swift
//  Core
//
//  Created by Atilla Özder on 16.09.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import RxSwift

class LandImageCellView: ImageCellView {
    
    let categoryNameLabel: UILabel = {
        let lbl = UILabel()
        lbl.lineBreakMode = .byTruncatingTail
        lbl.numberOfLines = 2
        lbl.font = .boldSystemFont(ofSize: 22)
        lbl.textColor = .white
        return lbl
    }()
    
    override func setup() {
        super.setup()
        self.insertSubview(categoryNameLabel, at: 1)
        let insets = UIEdgeInsets(top: 0, left: 8, bottom: -8, right: -8)
        categoryNameLabel.pinBottom(to: imageView.bottomAnchor, constant: insets.bottom)
        categoryNameLabel.pinEdgesToView(imageView, insets: insets, exclude: [.top, .bottom])
    }
    
    override func bind(to viewModel: Identifiable) {
        guard let cvm = viewModel as? CategoryCellViewModel else { return }
        
        categoryNameLabel.text = cvm.categoryNameText
        imageView.image = cvm.landImagePrefetcher.image
        cvm.landImagePrefetcher
            .imageObservable
            .bind(to: imageView.rx.image)
            .disposed(by: bag)
    }
    
}
