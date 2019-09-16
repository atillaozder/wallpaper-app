//
//  UIView+AutoLayout.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

enum SizePriority {
    case required
    case low
    case lowerWidth
    case lowerHeight
    
    var width: UILayoutPriority {
        return value.width
    }
    
    var height: UILayoutPriority {
        return value.height
    }
    
    private var value: (width: UILayoutPriority, height: UILayoutPriority) {
        switch self {
        case .required:
            return (width: .required, height: .required)
        case .lowerWidth:
            return (width: .low, height: .required)
        case .lowerHeight:
            return (width: .required, height: .low)
        case .low:
            return (width: .low, height: .low)
        }
    }
}

extension UILayoutPriority {
    static let low: UILayoutPriority = .init(999)
}

extension UIView {
    
    var windowSafeAreaInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
        }
        return .zero
    }
    
    var safeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11, *) {
            return safeAreaLayoutGuide.topAnchor
        }
        return topAnchor
    }
    
    var safeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11, *) {
            return safeAreaLayoutGuide.bottomAnchor
        }
        return bottomAnchor
    }
    
    var safeLeadingAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11, *) {
            return safeAreaLayoutGuide.leadingAnchor
        }
        return leadingAnchor
    }
    
    var safeTrailingAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11, *) {
            return safeAreaLayoutGuide.trailingAnchor
        }
        return trailingAnchor
    }
    
    @discardableResult
    func pinCenterX(
        to: NSLayoutAnchor<NSLayoutXAxisAnchor>,
        constant: CGFloat = 0,
        priority: UILayoutPriority = .required) -> NSLayoutConstraint
    {
        self.translatesAutoresizingMaskIntoConstraints = false
        let c = self.centerXAnchor.constraint(equalTo: to, constant: constant)
        c.priority = priority
        c.isActive = true
        return c
    }
    
    @discardableResult
    func pinCenterY(
        to: NSLayoutAnchor<NSLayoutYAxisAnchor>,
        constant: CGFloat = 0,
        priority: UILayoutPriority = .required) -> NSLayoutConstraint
    {
        self.translatesAutoresizingMaskIntoConstraints = false
        let c = self.centerYAnchor.constraint(equalTo: to, constant: constant)
        c.priority = priority
        c.isActive = true
        return c
    }
    
    @discardableResult
    func pinTrailing(
        to: NSLayoutAnchor<NSLayoutXAxisAnchor>,
        constant: CGFloat = 0,
        priority: UILayoutPriority = .required) -> NSLayoutConstraint
    {
        self.translatesAutoresizingMaskIntoConstraints = false
        let c = self.trailingAnchor.constraint(equalTo: to, constant: constant)
        c.priority = priority
        c.isActive = true
        return c
    }
    
    @discardableResult
    func pinLeading(
        to: NSLayoutAnchor<NSLayoutXAxisAnchor>,
        constant: CGFloat = 0,
        priority: UILayoutPriority = .required) -> NSLayoutConstraint
    {
        self.translatesAutoresizingMaskIntoConstraints = false
        let c = self.leadingAnchor.constraint(equalTo: to, constant: constant)
        c.priority = priority
        c.isActive = true
        return c
    }
    
    @discardableResult
    func pinTop(
        to: NSLayoutAnchor<NSLayoutYAxisAnchor>,
        constant: CGFloat = 0,
        priority: UILayoutPriority = .required) -> NSLayoutConstraint
    {
        self.translatesAutoresizingMaskIntoConstraints = false
        let c = self.topAnchor.constraint(equalTo: to, constant: constant)
        c.priority = priority
        c.isActive = true
        return c
    }
    
    @discardableResult
    func pinBottom(
        to: NSLayoutAnchor<NSLayoutYAxisAnchor>,
        constant: CGFloat = 0,
        priority: UILayoutPriority = .required) -> NSLayoutConstraint
    {
        self.translatesAutoresizingMaskIntoConstraints = false
        let c = self.bottomAnchor.constraint(equalTo: to, constant: constant)
        c.priority = priority
        c.isActive = true
        return c
    }
    
    func pinEdgesUnSafeArea(insets: UIEdgeInsets = .zero) {
        guard let superView = superview else { return }
        self.pinTop(to: superView.topAnchor, constant: insets.top)
        self.pinBottom(to: superView.bottomAnchor, constant: insets.bottom)
        self.pinTrailing(to: superView.trailingAnchor, constant: insets.right)
        self.pinLeading(to: superView.leadingAnchor, constant: insets.left)
    }
    
    func pinEdgesToSuperview(insets: UIEdgeInsets = .zero) {
        guard let superView = superview else { return }
        pinEdgesToView(superView, insets: insets)
    }
    
    func pinEdgesToView(_ view: UIView,
                        insets: UIEdgeInsets = .zero,
                        exclude: [NSLayoutConstraint.Attribute] = []) {
        self.translatesAutoresizingMaskIntoConstraints = false
        let dims = [
            leadingAnchor.constraint(equalTo: view.safeLeadingAnchor, constant: insets.left),
            topAnchor.constraint(equalTo: view.safeTopAnchor, constant: insets.top),
            bottomAnchor.constraint(equalTo: view.safeBottomAnchor, constant: insets.bottom),
            trailingAnchor.constraint(equalTo: view.safeTrailingAnchor, constant: insets.right)
        ]
        
        let constraints = dims.filter { !exclude.contains($0.firstAttribute) }
        NSLayoutConstraint.activate(constraints)
    }
    
    func pinCenterOfSuperview(insets: UIEdgeInsets = .zero) {
        guard let superView = superview else { return }
        self.pinCenterX(to: superView.centerXAnchor)
        self.pinCenterY(to: superView.centerYAnchor)
    }
    
    func pin(size: CGSize, priority: SizePriority = .required) {
        if size.width != 0 {
            self.pinWidth(to: size.width, priority: priority.width)
        }
        
        if size.height != 0 {
            self.pinHeight(to: size.height, priority: priority.height)
        }
    }
    
    func pinSquare(_ length: CGFloat, priority: SizePriority = .required) {
        self.pin(size: .init(width: length, height: length), priority: priority)
    }
    
    @discardableResult
    private func pin(
        _ anchor: NSLayoutDimension,
        to dim: NSLayoutDimension? = nil,
        constant: CGFloat = 0,
        multiplier: CGFloat = 1,
        priority: UILayoutPriority) -> NSLayoutConstraint
    {
        self.translatesAutoresizingMaskIntoConstraints = false
        let constraint: NSLayoutConstraint
        
        if let dimension = dim {
            constraint = anchor.constraint(equalTo: dimension, multiplier: multiplier)
        } else {
            constraint = anchor.constraint(equalToConstant: constant)
        }
        
        constraint.priority = priority
        constraint.isActive = true
        return constraint
    }
    
    func pinHeight(to anchor: NSLayoutDimension,
                   priority: UILayoutPriority = .required,
                   multiplier: CGFloat = 1) {
        self.pin(heightAnchor, to: anchor, multiplier: multiplier, priority: priority)
    }
    
    func pinHeight(to constant: CGFloat, priority: UILayoutPriority = .required) {
        self.pin(heightAnchor, constant: constant, priority: priority)
    }
    
    func pinWidth(to anchor: NSLayoutDimension,
                  priority: UILayoutPriority = .required,
                  multiplier: CGFloat = 1) {
        self.pin(widthAnchor, to: anchor, multiplier: multiplier, priority: priority)
    }
    
    func pinWidth(to constant: CGFloat, priority: UILayoutPriority = .required) {
        self.pin(widthAnchor, constant: constant, priority: priority)
    }
}
