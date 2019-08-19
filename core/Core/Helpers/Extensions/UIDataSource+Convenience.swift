//
//  UIDataSource+Convenience.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import UIKit

extension UITableViewCell {
    static var identifier: String {
        return String(describing: self)
    }
}

extension UICollectionViewCell {
    static var identifier: String {
        return String(describing: self)
    }
}

extension UITableView {
    func registerCell<Cell: UITableViewCell>(_ cell: Cell.Type) {
        self.register(cell, forCellReuseIdentifier: cell.identifier)
    }
    
    func dequeueReusableCell<Cell: UITableViewCell>(for indexPath: IndexPath) -> Cell {
        return self.dequeueReusableCell(withIdentifier: Cell.identifier, for: indexPath) as! Cell
    }
}

extension UICollectionView {
    func registerCell<Cell: UICollectionViewCell>(_ cell: Cell.Type) {
        self.register(cell, forCellWithReuseIdentifier: cell.identifier)
    }
    
    func dequeueReusableCell<Cell: UICollectionViewCell>(for indexPath: IndexPath) -> Cell {
        return self.dequeueReusableCell(withReuseIdentifier: Cell.identifier, for: indexPath) as! Cell
    }
}
