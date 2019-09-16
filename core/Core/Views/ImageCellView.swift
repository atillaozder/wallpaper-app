//
//  ImageCellView.swift
//  Core
//
//  Created by Atilla Özder on 16.09.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import RxSwift

class ImageCellView: UIView {
    
    private(set) var bag: DisposeBag = DisposeBag()
    
    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.isUserInteractionEnabled = false
        iv.backgroundColor = .defaultImageBackground
        iv.sd_imageTransition = .fade
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        backgroundColor = .defaultImageBackground
        self.addSubview(imageView)
        imageView.pinEdgesToSuperview()
    }
    
    
    func prepareForReuse() {
        bag = DisposeBag()
    }
    
    func bind(to viewModel: Identifiable) {
        guard let cvm = viewModel as? ImageCellViewModel else { return }
        
        imageView.image = cvm.portraitImagePrefetcher.image
        cvm.portraitImagePrefetcher
            .imageObservable
            .bind(to: imageView.rx.image)
            .disposed(by: bag)
    }
}
