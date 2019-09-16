//
//  SideMenuHeaderView.swift
//  Core
//
//  Created by Atilla Özder on 16.09.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation

struct SideMenuButtonFactory {
    func createButton() -> UIButton {
        let btn = UIButton(type: .custom)
        btn.tintAdjustmentMode = .normal
        btn.adjustsImageWhenHighlighted = false
        btn.adjustsImageWhenDisabled = false
        btn.titleLabel?.font = .boldSystemFont(ofSize: 15)
        btn.contentEdgeInsets = .init(top: 0, left: 12, bottom: 0, right: 0)
        btn.contentHorizontalAlignment = .left
        btn.setTitleColor(.defaultTextColor, for: .normal)
        return btn
    }
}

class SideMenuHeaderView: UIStackView {
    
    lazy var favoritesButton: UIButton = {
        let btn = SideMenuButtonFactory().createButton()
        btn.setTitle(Localization.favorites, for: .normal)
        return btn
    }()
    
    lazy var privacyPolicyButton: UIButton = {
        let btn = SideMenuButtonFactory().createButton()
        btn.setTitle("Privacy Policy", for: .normal)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        self.distribution = .fillEqually
        self.alignment = .fill
        self.axis = .vertical
        self.spacing = 0
        self.addArrangedSubview(favoritesButton)
        self.addArrangedSubview(privacyPolicyButton)
    }
}
