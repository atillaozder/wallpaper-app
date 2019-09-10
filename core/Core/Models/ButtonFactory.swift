//
//  ButtonFactory.swift
//  Core
//
//  Created by Atilla Özder on 9.09.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import UIKit

struct ButtonFactory {
    func generateButton() -> UIButton {
        let btn = UIButton(type: .custom)
        btn.setTitleColor(.defaultTextColor, for: .normal)
        btn.titleLabel?.numberOfLines = 0
        btn.titleLabel?.lineBreakMode = .byWordWrapping
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        btn.backgroundColor = .white
        btn.layer.borderColor = UIColor.defaultBorder.cgColor
        btn.layer.borderWidth = 0.5
        btn.tintAdjustmentMode = .normal
        btn.adjustsImageWhenHighlighted = false
        btn.adjustsImageWhenDisabled = false
        return btn
    }
}
