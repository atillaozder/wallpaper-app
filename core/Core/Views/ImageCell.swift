//
//  ImageCell.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import RxSwift
import RxCocoa

class ImageCell: CollectionCell {
    
    var cellView: ImageCellView? {
        didSet {
            setup()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellView?.prepareForReuse()
    }
    
    func setup() {
        if let view = self.cellView {
            contentView.addSubview(view)
            view.pinEdgesToSuperview()
        }
    }
    
    override func bind(to viewModel: Identifiable) {
        cellView?.bind(to: viewModel)
    }
}
