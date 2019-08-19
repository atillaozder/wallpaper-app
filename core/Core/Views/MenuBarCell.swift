//
//  MenuBarCell.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import UIKit

class MenuBarCell: CollectionCell {
    
    lazy var label: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.lineBreakMode = .byTruncatingTail
        lbl.numberOfLines = 1
        lbl.font = .systemFont(ofSize: 14.5, weight: .semibold)
        lbl.backgroundColor = .white
        lbl.textColor = UIColor.gray
        return lbl
    }()
    
    override var isHighlighted: Bool {
        didSet {
            label.backgroundColor = isHighlighted ? UIColor.groupTableViewBackground : UIColor.white
        }
    }
    
    override var isSelected: Bool {
        didSet {
            label.textColor = isSelected ? .defaultTextColor : UIColor.gray
        }
    }
    
    override func setup() {
        super.setup()
        self.contentView.addSubview(label)
        label.pinEdgesToView(contentView, insets: .zero, exclude: [.bottom])
        label.pin(size: .init(width: 0, height: MenuBar.barHeight - 0.5))
        
        let separator = UIView()
        separator.backgroundColor = .lightGray
        self.contentView.addSubview(separator)
        
        separator.pinEdgesToView(contentView, insets: .zero, exclude: [.top])
        separator.pinTop(to: label.bottomAnchor)
    }
}
