//
//  PhotoViewController.swift
//  Core
//
//  Created by Atilla Özder on 4.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import UIKit
import RxSwift
import Photos
import GoogleMobileAds
import SDWebImage

class PhotoViewController: UIViewController {
    
    private let bag: DisposeBag = DisposeBag()
    private let viewModel: PhotoViewModel
    
    private var didReceiveAd: Bool = false
    let kDownloadButtonHeight: CGFloat = 50
    var downloadButtonBottomConstraint: NSLayoutConstraint?
    
    lazy var favImageView: UIImageView = {
        let iv = UIImageView()
        iv.addTapGesture(self, action: #selector(favoriteTapped))
        iv.tintColor = .defaultTextColor
        iv.contentMode = .center
        iv.pin(size: .init(width: 50, height: 44))
        return iv
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .gray)
        ai.backgroundColor = .white
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
        insets.bottom = kDownloadButtonHeight + view.windowSafeAreaInsets.bottom
        sv.contentInset = insets
        // Default values before image is loaded to ignore zooming
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
        iv.backgroundColor = .defaultImageBackground
        return iv
    }()
    
    lazy var bannerView: GADBannerView = {
        return getBannerView()
    }()
    
    init(image: Image) {
        self.viewModel = PhotoViewModel(image: image)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.viewModel = PhotoViewModel(image: nil)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateMinZoomScale(forSize: scrollView.bounds.size)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        InterstitialHandler.shared().setDelegate(self)
        InterstitialHandler.shared().increase()
        view.backgroundColor = .white
        
        view.addSubview(activityIndicator)
        activityIndicator.pinCenterOfSuperview()
        activityIndicator.startAnimating()
        
        view.addSubview(scrollView)
        scrollView.pinEdgesToSuperview()
        
        scrollView.addSubview(imageView)
        imageViewTopConstraint = imageView.pinTop(to: scrollView.topAnchor)
        imageViewLeadingConstraint = imageView.pinLeading(to: scrollView.leadingAnchor)
        imageViewTrailingConstraint = imageView.pinTrailing(to: scrollView.trailingAnchor)
        imageViewBottomConstraint = imageView.pinBottom(to: scrollView.bottomAnchor)
        
        view.addSubview(bannerView)
        bannerView.pinCenterX(to: view.centerXAnchor)
        bannerView.pinBottom(to: view.safeBottomAnchor)

        setupButtons()
        bindUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTapGesture()
        scrollView.delegate = self
        bannerView.delegate = self
    }
    
    private func setupButtons() {
        setupBarButtons()
    
        let btn = UIButton(type: .custom)
        btn.setTitle(Localization.save, for: .normal)
        btn.setTitleColor(.defaultTextColor, for: .normal)
        btn.titleLabel?.numberOfLines = 0
        btn.titleLabel?.lineBreakMode = .byWordWrapping
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        btn.addTarget(self, action: #selector(downloadTapped), for: .touchUpInside)
        btn.backgroundColor = .white
        btn.layer.borderColor = UIColor.defaultBorder.cgColor
        btn.layer.borderWidth = 0.5
        
        view.insertSubview(btn, at: 1)
        btn.pinEdgesToView(view, insets: .zero, exclude: [.top, .bottom])
        self.downloadButtonBottomConstraint = btn.pinBottom(to: view.safeBottomAnchor)
        btn.pinHeight(to: kDownloadButtonHeight)
        view.bringSubviewToFront(btn)
    }
    
    private func setupBarButtons() {
        let shareImg = UIImage(named: "ic_share")
        let shareView = UIImageView(image: shareImg)
        shareView.addTapGesture(self, action: #selector(shareTapped(_:)))
        shareView.tintColor = .defaultTextColor
        shareView.contentMode = .center
        shareView.pin(size: .init(width: 50, height: 44))
        let shareBarButton = UIBarButtonItem(customView: shareView)
        
        let favoriteBarButton = UIBarButtonItem(customView: favImageView)
        let value = StorageHelper.shared().value(for: viewModel.item)
        setImageView(from: value)
        self.navigationItem.setRightBarButtonItems([shareBarButton, favoriteBarButton],
                                                   animated: false)
    }
    
    func bindUI() {
        viewModel.image
            .asDriver()
            .drive(onNext: { (image) in
                self.setImage(image)
            }).disposed(by: bag)
    }
    
    func setImage(_ image: UIImage?) {
        self.imageView.image = image
        
        if image != nil {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
        }

        self.imageView.layoutIfNeeded()
        self.view.sendSubviewToBack(scrollView)
        
        DispatchQueue.main.async {
            let size = self.scrollView.bounds.size
            self.updateConstraints(forSize: size)
            self.updateMinZoomScale(forSize: size)
        }
    }
    
    @objc
    func shareTapped(_ sender: UITapGestureRecognizer) {
        InterstitialHandler.shared().increase()
        guard let image = imageView.image?.jpegData(compressionQuality: 1.0) else { return }
        let viewController = UIActivityViewController(activityItems: [image], applicationActivities: [])
        viewController.excludedActivityTypes = [.saveToCameraRoll]
        viewController.popoverPresentationController?.sourceView = sender.view ?? self.view
        self.present(viewController, animated: true, completion: nil)
    }
    
    @objc
    func favoriteTapped() {
        let newValue = !StorageHelper.shared().value(for: viewModel.item)
        viewModel.toggleFavorite()
        setImageView(from: newValue)
    }
    
    func setImageView(from value: Bool) {
        let image = value ? UIImage(named: "ic_filled_heart") : UIImage(named: "ic_empty_heart")
        let tintColor: UIColor = value ? .red : .defaultTextColor
        favImageView.image = image?.withRenderingMode(.alwaysTemplate)
        favImageView.tintColor = tintColor
    }
    
    @objc
    private func downloadTapped() {        
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                if status == .authorized {
                    self.saveImage()
                }
            }
        case .authorized:
            self.saveImage()
        case .denied:
            self.askPermission()
        case .restricted:
            self.askPermission()
        @unknown default:
            self.askPermission()
        }
    }
    
    private func saveImage() {
        viewModel.save() { [weak self] (success, error) in
            guard let `self` = self else { return }
            if success {
                DispatchQueue.main.async {
                    let inset = self.kDownloadButtonHeight + self.bannerView.frame.height
                    self.showToast(with: Localization.saved, additionalInset: inset)
                }
            } else {
                DispatchQueue.main.async {
                    self.showToast(with: "Error ⚠️")
                }
            }

            if let err = error {
                #if DEBUG
                print("⚠️ Error while trying to save \(err.localizedDescription)")
                #endif
            }
        }
    }
    
    private func askPermission() {
        let alertController = UIAlertController(
            title: Localization.photoPermissionTitle,
            message: Localization.photoPermissionMessage,
            preferredStyle: .alert
        )
        
        let openSettings = UIAlertAction(
            title: Localization.openSettingsTitle,
            style: .default) { (_) in
                guard let url = UIApplication.openSettingsURLString.asURL() else { return }
                let shared = UIApplication.shared
                if shared.canOpenURL(url) {
                    shared.open(url, completionHandler: { (_) in
                        alertController.dismiss(animated: true, completion: nil)
                    })
                }
        }
        
        let cancel = UIAlertAction(title: Localization.cancel, style: .cancel, handler: nil)
        alertController.addAction(cancel)
        alertController.addAction(openSettings)
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func updateMinZoomScale(forSize size: CGSize) {
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
    
    private func updateConstraints(forSize size: CGSize) {
        let yOffset = max(0, (size.height - imageView.frame.height) / 2)
        imageViewTopConstraint?.constant = yOffset
        imageViewBottomConstraint?.constant = yOffset
        
        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
        imageViewLeadingConstraint?.constant = xOffset
        imageViewTrailingConstraint?.constant = xOffset

        view.layoutIfNeeded()
    }
}

extension PhotoViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraints(forSize: scrollView.bounds.size)
    }
}

extension PhotoViewController: GADBannerViewDelegate {
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        var insets = UIEdgeInsets.zero
        insets.bottom = bannerView.frame.height + kDownloadButtonHeight + view.windowSafeAreaInsets.bottom
        scrollView.contentInset = insets
        
        if !self.didReceiveAd {
            downloadButtonBottomConstraint?.constant -= bannerView.frame.height
            self.didReceiveAd = true
        }
    }
}

extension PhotoViewController: InterstitialHandlerDelegate {
    func interstitialHandler(_ handler: InterstitialHandler,
                             didShowInterstitial interstitial: GADInterstitial) {
        interstitial.present(fromRootViewController: self)
    }
}

extension PhotoViewController {
    private func setTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        tapGesture.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(tapGesture)
    }
    
    @objc
    func handleDoubleTap(_ sender: UITapGestureRecognizer) {
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
