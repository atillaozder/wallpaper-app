//
//  ImageActionBar.swift
//  Core
//
//  Created by Atilla Özder on 16.09.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation

struct ActionButtonFactory {
    func createButton() -> UIButton {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .defaultTextColor
        btn.tintAdjustmentMode = .normal
        btn.adjustsImageWhenHighlighted = false
        btn.adjustsImageWhenDisabled = false
        btn.contentHorizontalAlignment = .center
        btn.imageView?.tintColor = .white
        return btn
    }
}

class ImageActionBar: UIStackView {
    
    static var defaultHeight: CGFloat {
        return 50
    }
    
    var buttonBarBottomConstraint: NSLayoutConstraint?
    
    lazy var downloadButton: UIButton = {
        let btn = ActionButtonFactory().createButton()
        let image = Asset.icDownload.image.withRenderingMode(.alwaysTemplate)
        btn.setImage(image, for: .normal)
        return btn
    }()
    
    lazy var shareButton: UIButton = {
        let btn = ActionButtonFactory().createButton()
        let image = Asset.icUpload.image.withRenderingMode(.alwaysTemplate)
        btn.setImage(image, for: .normal)
        return btn
    }()
    
    lazy var editButton: UIButton = {
        let btn = ActionButtonFactory().createButton()
        let image = Asset.icEdit.image.withRenderingMode(.alwaysTemplate)
        btn.setImage(image, for: .normal)
        return btn
    }()
    
    lazy var favoriteButton: UIButton = {
        let btn = ActionButtonFactory().createButton()
        let image = Asset.icEmptyStar.image.withRenderingMode(.alwaysTemplate)
        btn.setImage(image, for: .normal)
        return btn
    }()
    
    lazy var previewButton: UIButton = {
        let btn = ActionButtonFactory().createButton()
        let image = Asset.icPreview.image.withRenderingMode(.alwaysTemplate)
        btn.setImage(image, for: .normal)
        return btn
    }()
    
    var isFavorited: Bool = false {
        willSet {
            let image = newValue ? Asset.icFilledStar.image : Asset.icEmptyStar.image
            favoriteButton.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        self.distribution = .fillEqually
        self.alignment = .fill
        self.axis = .horizontal
        self.spacing = 0
        
        [downloadButton, shareButton, favoriteButton, editButton, previewButton].forEach { (btn) in
            self.addArrangedSubview(btn)
        }
    }
}
