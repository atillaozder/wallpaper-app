//
//  SideMenuCell.swift
//  Core
//
//  Created by Atilla Özder on 16.09.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation

class SideMenuCell: CollectionCell {
    
    let categoryNameLabel: UILabel = {
        let lbl = UILabel()
        lbl.lineBreakMode = .byTruncatingTail
        lbl.numberOfLines = 1
        lbl.font = .systemFont(ofSize: 15)
        lbl.textColor = .defaultTextColor
        return lbl
    }()
    
    override func setupViews() {
        super.setupViews()
        contentView.addSubview(categoryNameLabel)
        categoryNameLabel.pinEdgesToSuperview(insets: .init(top: 0, left: 12, bottom: 0, right: -12))
    }
    
    override func bind(to viewModel: Identifiable) {
        guard let cvm = viewModel as? CategoryCellViewModel else { return }
        self.categoryNameLabel.text = cvm.categoryNameText
    }
}
