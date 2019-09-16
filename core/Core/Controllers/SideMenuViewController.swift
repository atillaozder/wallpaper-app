//
//  SideMenuViewController.swift
//  Core
//
//  Created by Atilla Özder on 16.09.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation

class SideMenuViewController: PagedCollectionViewController {
    
    private lazy var viewModel = CategoryViewModel()
    private lazy var headerView = SideMenuHeaderView()
    
    var cellHeight: CGFloat {
        return 40
    }
    
    override var pageViewModel: PagedViewModelType! {
        return viewModel
    }
    
    override func getCollectionView() -> UICollectionView {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = .init(width: UIConstants.kSideMenuWidth, height: cellHeight)
        flowLayout.sectionInset = .zero
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .vertical
        flowLayout.headerReferenceSize = .zero
        flowLayout.footerReferenceSize = .zero
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        cv.backgroundColor = .white
        cv.isPagingEnabled = false
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.alwaysBounceVertical = true
        cv.bounces = true
        cv.delegate = self
        cv.prefetchDataSource = self
        cv.registerCell(SideMenuCell.self)
        return cv
    }
    
    override func setupViews() {
        super.setupViews()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        headerView.favoritesButton.addTarget(
            self, action: #selector(favoritesTapped), for: .touchUpInside)
        headerView.privacyPolicyButton.addTarget(
            self, action: #selector(privacyPolicyTapped), for: .touchUpInside)
    }
    
    override func setupCollectionView() {
        view.addSubview(headerView)
        let insets: UIEdgeInsets = .init(top: 8, left: 0, bottom: 0, right: 0)
        if #available(iOS 11.0, *) {
            headerView.pinEdgesToView(view, insets: insets, exclude: [.bottom])
        } else {
            headerView.pinEdgesToView(view, exclude: [.top, .bottom])
            headerView.pinTop(to: topLayoutGuide.bottomAnchor, constant: insets.top)
        }
        
        headerView.pinHeight(to: cellHeight * 2)
        view.addSubview(collectionView)
        collectionView.pinEdgesToView(view, exclude: [.top])
        collectionView.pinTop(to: headerView.bottomAnchor)
    }
    
    override func setupBanner() {
        return
    }
    
    override func initOutputBinding() {
        super.initOutputBinding()
        viewModel.output
            .dataSource
            .drive(collectionView.rx.items(
                cellIdentifier: SideMenuCell.identifier,
                cellType: SideMenuCell.self)) { (item, identifiable, cell) in
                    cell.bind(to: identifiable)
            }.disposed(by: bag)
    }
    
    override func showNextPageIndicator() {
        return
    }
    
    @objc
    func favoritesTapped() {
        let viewController = FavoritesViewController(viewModel: FavoritesViewModel())
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc
    func privacyPolicyTapped() {
        if let url = ApiConstants.privacyPolicyURLString.asURL() {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

extension SideMenuViewController {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        if let cvm = viewModel.cellViewModel(at: indexPath.item) as? CategoryCellViewModel {
            navigationController?.pushViewController(cvm.getViewController(), animated: true)
        }
    }
}
