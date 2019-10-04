//
//  MenuBar.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

protocol MenuBarScrollDelegate: class {
    func menuBar(_ menuBar: MenuBar, didSelectItemAt indexPath: IndexPath)
}

public class MenuBar: UIView {
    
    static let defaultBarHeight: CGFloat = 40
    weak var delegate: MenuBarScrollDelegate?
    var barLeftAnchorConstraint: NSLayoutConstraint?
    
    var startIndex = 0
    var titles: [String] = [] {
        didSet {
            collectionView.reloadData()
            separator.pinWidth(to: widthAnchor, multiplier: 1 / CGFloat(titles.count))
            scroll(at: startIndex, animated: false)
        }
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .darkTheme
        cv.registerCell(MenuBarCell.self)
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.isScrollEnabled = false
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    lazy var separator: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.pinHeight(to: 1)
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        self.addSubview(collectionView)
        collectionView.pinEdgesToSuperview()
        
        self.addSubview(separator)
        barLeftAnchorConstraint = separator.leftAnchor.constraint(equalTo: leftAnchor)
        barLeftAnchorConstraint?.isActive = true
        separator.pinBottom(to: bottomAnchor)
    }
    
    func scroll(at index: Int, animated: Bool = true) {
        let indexPath = IndexPath(item: Int(index), section: 0)
        self.collectionView.selectItem(
            at: indexPath,
            animated: animated,
            scrollPosition: .centeredHorizontally)
    }
    
    func updateIndicator(_ xOffset: CGFloat) {
        barLeftAnchorConstraint?.constant = xOffset
    }
}

extension MenuBar: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath) as MenuBarCell
        cell.label.text = titles[indexPath.item]
        cell.tintColor = UIColor(red: 91, green: 14, blue: 13)
        return cell
    }
}

extension MenuBar: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView,
                               didSelectItemAt indexPath: IndexPath) {
        self.delegate?.menuBar(self, didSelectItemAt: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / CGFloat(titles.count),
                      height: frame.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

