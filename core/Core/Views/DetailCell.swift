//
//  DetailCell.swift
//  Core
//
//  Created by Atilla Özder on 10.10.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import UIKit

class DetailCell: CollectionCell {
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .white)
        ai.backgroundColor = .darkTheme
        ai.hidesWhenStopped = true
        return ai
    }()
    
    lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        sv.bounces = true
        sv.bouncesZoom = true
        sv.clipsToBounds = true
        sv.decelerationRate = .fast
        sv.contentInset = .zero
        sv.layer.speed = 2.5
        var insets = UIEdgeInsets.zero
        insets.bottom += ImageActionBar.defaultHeight
        insets.bottom += contentView.windowSafeAreaInsets.bottom
        sv.contentInset = insets
        sv.maximumZoomScale = 1
        sv.minimumZoomScale = 1
        return sv
    }()
    
    private var imageViewBottomConstraint: NSLayoutConstraint?
    private var imageViewLeadingConstraint: NSLayoutConstraint?
    private var imageViewTopConstraint: NSLayoutConstraint?
    private var imageViewTrailingConstraint: NSLayoutConstraint?
    
    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleToFill
        iv.isUserInteractionEnabled = true
        iv.clipsToBounds = true
        iv.sd_imageTransition = .fade
        iv.backgroundColor = .imageBackground
        return iv
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateMinZoomScale(for: scrollView.frame.size)
    }
    
    override func setupViews() {
        super.setupViews()
        contentView.addSubview(activityIndicator)
        activityIndicator.pinCenterOfSuperview()
        activityIndicator.startAnimating()

        contentView.addSubview(scrollView)
        scrollView.pinEdgesToSuperview()

        scrollView.addSubview(imageView)
        imageViewTopConstraint = imageView.pinTop(to: scrollView.topAnchor)
        imageViewLeadingConstraint = imageView.pinLeading(to: scrollView.leadingAnchor)
        imageViewTrailingConstraint = imageView.pinTrailing(to: scrollView.trailingAnchor)
        imageViewBottomConstraint = imageView.pinBottom(to: scrollView.bottomAnchor)
        
        setupTapGesture()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        scrollView.delegate = nil
    }
    
    func bind(to viewModel: ImageCellViewModel) {
        viewModel.loadImage()
        scrollView.delegate = self
        
        viewModel.image
            .asDriver()
            .drive(onNext: { (image) in
                self.setImage(image)
            }).disposed(by: bag)
    }
    
    private func setImage(_ image: UIImage?) {
        self.imageView.image = image
        
        if image != nil {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
        }

        self.imageView.layoutIfNeeded()
        self.contentView.sendSubviewToBack(scrollView)
        
        DispatchQueue.main.async {
            let size = self.scrollView.bounds.size
            self.updateConstraints(for: size)
            self.updateMinZoomScale(for: size)
            self.scrollView.setContentOffset(.zero, animated: false)
        }
    }
    
    private func updateMinZoomScale(for size: CGSize) {
        if imageView.bounds.width > 0, imageView.bounds.height > 0 {
            let widthScale = size.width / imageView.bounds.width
            let heightScale = size.height / imageView.bounds.height

            let minScale = min(widthScale, heightScale)
            let maxScale = max(widthScale, heightScale) + 1

            scrollView.minimumZoomScale = minScale
            scrollView.zoomScale = minScale
            scrollView.maximumZoomScale = maxScale
        }
    }

    private func updateConstraints(for size: CGSize) {
        let yOffset = max(0, (size.height - imageView.frame.height) / 2)
        imageViewTopConstraint?.constant = yOffset
        imageViewBottomConstraint?.constant = yOffset

        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
        imageViewLeadingConstraint?.constant = xOffset
        imageViewTrailingConstraint?.constant = xOffset

        contentView.layoutIfNeeded()
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(
            target: self, action: #selector(handleDoubleTap(_:)))
        tapGesture.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        var zoomScale = scrollView.zoomScale
        let maxScale = scrollView.maximumZoomScale
        
        // The difference is too small to take into account, simply ignore the difference
        if (maxScale - zoomScale < 0.1) {
            zoomScale = maxScale
        }
        
        if maxScale != zoomScale {
            self.zoom(to: sender.location(in: imageView), scale: maxScale)
        } else {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        }
    }
    
    private func zoom(to point: CGPoint, scale: CGFloat) {
        let bounds = scrollView.bounds.size
        let width = bounds.width / scale
        let height = bounds.height / scale
        let size = CGSize(width: width, height: height)
        
        let posX = point.x - size.width / 2
        let posY = point.y - size.height / 2
        let origin = CGPoint(x: posX, y: posY)
        
        let zoomRect = CGRect(origin: origin, size: size)
        scrollView.zoom(to: zoomRect, animated: true)
    }
}

extension DetailCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraints(for: scrollView.bounds.size)
    }
}
