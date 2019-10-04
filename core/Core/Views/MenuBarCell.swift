//
//  MenuBarCell.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

class MenuBarCell: CollectionCell {
    
    let label: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.lineBreakMode = .byTruncatingTail
        lbl.numberOfLines = 1
        lbl.font = .systemFont(ofSize: 14.5, weight: .semibold)
        lbl.backgroundColor = .darkTheme
        lbl.textColor = UIColor.gray
        lbl.adjustsFontSizeToFitWidth = true
        lbl.minimumScaleFactor = 0.5
        return lbl
    }()
    
    override var isHighlighted: Bool {
        didSet {
            if !isSelected {
                label.textColor = isHighlighted ?
                    UIColor.gray.withAlphaComponent(0.5) :
                    UIColor.gray
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            label.textColor = isSelected ? .white : .lightGray
        }
    }
    
    override func setupViews() {
        super.setupViews()
        self.contentView.addSubview(label)
        label.pinEdgesToSuperview()
        
        let separator = UIView()
        separator.backgroundColor = .gray
        self.contentView.addSubview(separator)
        separator.pinEdgesToView(contentView, exclude: [.top])
        separator.pinHeight(to: 0.5)
    }
}
