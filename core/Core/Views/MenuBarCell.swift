//
//  MenuBarCell.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

class MenuBarCell: CollectionCell {
    
    static var labelFont: UIFont {
        return .systemFont(ofSize: 14.5, weight: .semibold)
    }
    
    let label: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.lineBreakMode = .byTruncatingTail
        lbl.numberOfLines = 1
        lbl.font = MenuBarCell.labelFont
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
    }
}
