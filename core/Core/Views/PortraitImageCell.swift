//
//  PortraitImageCell.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import UIKit

class PortraitImageCell: CollectionCell {
    
    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.isUserInteractionEnabled = false
        iv.backgroundColor = .defaultImageBackground
        iv.sd_imageTransition = .fade
        return iv
    }()
    
    override func setup() {
        super.setup()
        backgroundColor = .defaultImageBackground
        contentView.backgroundColor = .defaultImageBackground
        contentView.addSubview(imageView)
        imageView.pinEdgesToSuperview()
    }
    
    override func bind(to viewModel: Identifiable) {
        super.bind(to: viewModel)
        guard let cvm = viewModel as? ImageCellViewModel else { return }
        
        imageView.image = cvm.portraitImagePrefetcher.cachedImage
        cvm.portraitImagePrefetcher
            .image
            .drive(imageView.rx.image)
            .disposed(by: bag)
    }
}
