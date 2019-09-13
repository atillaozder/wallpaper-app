//
//  MenuBar.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import UIKit

protocol MenuBarDelegate: class {
    func menuBar(_ menuBar: MenuBar, didScrollAt indexPath: IndexPath)
}

class MenuBar: UIView {
    
    static let barHeight: CGFloat = 40
    var barWidthConstraint: NSLayoutConstraint?
    var barLeftAnchorConstraint: NSLayoutConstraint?
    weak var delegate: MenuBarDelegate?
    
    var dataSource: [String] = [] {
        didSet {
            setupHorizontalBar()
            collectionView.reloadData()
        }
    }
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        cv.backgroundColor = .white
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.isScrollEnabled = false
        cv.delegate = self
        cv.dataSource = self
        cv.registerCell(MenuBarCell.self)
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(collectionView)
        self.collectionView.pinEdgesToSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupHorizontalBar() {
        let separator = UIView()
        separator.backgroundColor = .defaultTextColor
        
        self.addSubview(separator)
        barLeftAnchorConstraint = separator.leftAnchor.constraint(equalTo: leftAnchor)
        barLeftAnchorConstraint?.isActive = true
        
        separator.pinBottom(to: bottomAnchor)
        separator.pinWidth(to: widthAnchor, multiplier: 1 / CGFloat(dataSource.count))
        separator.pinHeight(to: 1)
    }
    
    func scroll(at index: Int, animated: Bool = true) {
        self.collectionView.selectItem(at: .init(item: index, section: 0),
                                       animated: animated,
                                       scrollPosition: .centeredHorizontally)
    }
    
    func scrollIndicator(at point: CGFloat) {
        let offsetX: CGFloat = self.frame.size.width / CGFloat(dataSource.count)
        let constant: CGFloat = offsetX * abs(point)
        DispatchQueue.main.async {
            self.barLeftAnchorConstraint?.constant = constant
        }
    }
}

extension MenuBar: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath) as MenuBarCell
        cell.label.text = dataSource[indexPath.item]
        cell.tintColor = UIColor(red: 91, green: 14, blue: 13)
        return cell
    }
}

extension MenuBar: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        self.delegate?.menuBar(self, didScrollAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width / CGFloat(dataSource.count), height: frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
