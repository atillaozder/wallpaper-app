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
import CropViewController
import GoogleMobileAds
import SDWebImage

class PhotoViewController: UIViewController {
    
    private let bag: DisposeBag = DisposeBag()
    private let viewModel: PhotoViewModel
    
    private var didReceiveAd: Bool = false
    let kDownloadButtonHeight: CGFloat = 50
    var downloadButtonBottomConstraint: NSLayoutConstraint?
    
    lazy var favBtn: UIButton = {
        let btn = ButtonFactory().generateButton()
        btn.contentHorizontalAlignment = .center
        btn.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        return btn
    }()
    
    var isFavorited: Bool = false {
        willSet {
            let image = newValue ? UIImage(named: "ic_filled_heart") : UIImage(named: "ic_empty_heart")
            let tintColor: UIColor = newValue ? .red : .defaultTextColor
            favBtn.setImage(image?.withRenderingMode(.alwaysTemplate), for: .normal)
            favBtn.imageView?.tintColor = tintColor
        }
    }
    
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
        
        let btn = ButtonFactory().generateButton()
        btn.setTitle(Localization.save, for: .normal)
        btn.addTarget(self, action: #selector(downloadTapped), for: .touchUpInside)
        
        self.isFavorited = StorageHelper.shared().value(for: viewModel.item)

        let sv = UIStackView(arrangedSubviews: [favBtn, btn])
        sv.distribution = .fillEqually
        sv.alignment = .fill
        sv.spacing = 0
        
        view.insertSubview(sv, at: 1)
        sv.pinEdgesToView(view, insets: .zero, exclude: [.top, .bottom])
        self.downloadButtonBottomConstraint = sv.pinBottom(to: view.safeBottomAnchor)
        sv.pinHeight(to: kDownloadButtonHeight)
        view.bringSubviewToFront(sv)
    }
    
    private func setupBarButtons() {
        let shareBarButton = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(shareTapped))
        shareBarButton.style = .done
        shareBarButton.imageInsets = .init(top: 0, left: 8, bottom: 0, right: 0)

        let editBarButton = UIBarButtonItem(
            barButtonSystemItem: .compose,
            target: self,
            action: #selector(editTapped))
        editBarButton.style = .done
        editBarButton.imageInsets = .init(top: 2, left: 0, bottom: 0, right: 8)

        let barButtons = [shareBarButton, editBarButton]
        barButtons.forEach { $0.tintColor = .defaultTextColor }
        self.navigationItem.setRightBarButtonItems(barButtons, animated: false)
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
    func shareTapped() {
        InterstitialHandler.shared().increase()
        guard let image = imageView.image?.jpegData(compressionQuality: 1.0) else { return }
        let viewController = UIActivityViewController(activityItems: [image], applicationActivities: [])
        viewController.excludedActivityTypes = [.saveToCameraRoll]
        viewController.popoverPresentationController?.sourceView = self.view
        self.present(viewController, animated: true, completion: nil)
    }
    
    @objc
    func editTapped() {
        getLibraryPermission { [weak self] (authorized) in
            guard let `self` = self else { return }
            authorized ? self.presentCropController() : self.askPermission()
        }
    }
    
    @objc
    func favoriteTapped() {
        let newValue = !StorageHelper.shared().value(for: viewModel.item)
        viewModel.toggleFavorite()
        self.isFavorited = newValue
    }

    @objc
    private func downloadTapped() {
        getLibraryPermission { [weak self] (authorized) in
            guard let `self` = self else { return }
            authorized ? self.saveImage() : self.askPermission()
        }
    }
    
    private func getLibraryPermission(completionHandler: @escaping ((Bool) -> Void)) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                if status == .authorized {
                    DispatchQueue.main.async {
                        completionHandler(true)
                    }
                }
            }
        case .authorized:
            DispatchQueue.main.async {
                completionHandler(true)
            }
        case .denied, .restricted:
            DispatchQueue.main.async {
                completionHandler(false)
            }
        @unknown default:
            DispatchQueue.main.async {
                completionHandler(false)
            }
        }
    }
    
    private func presentCropController() {
        if let image = self.imageView.image {
            let cropController = CropViewController(croppingStyle: .default, image: image)
            cropController.aspectRatioPreset = .presetCustom
            cropController.aspectRatioPickerButtonHidden = false
            cropController.toolbarPosition = .top
            cropController.delegate = self
            cropController.showActivitySheetOnDone = true
            self.present(cropController, animated: true, completion: nil)
        }
    }
    
    private func saveImage() {
        viewModel.save() { [weak self] (success, error) in
            guard let `self` = self else { return }
            if success {
                DispatchQueue.main.async {
                    let inset = self.kDownloadButtonHeight + self.bannerView.frame.height
                    self.showToast(with: Localization.saved,
                                   additionalInset: inset,
                                   shouldPresentInterstitial: true)
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
            preferredStyle: .alert)
        
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

extension PhotoViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController,
                            didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true, completion: nil)
        if !cancelled {
            InterstitialHandler.shared().triggerPresentingInterstitial()
        }
    }
}

extension PhotoViewController: InterstitialHandlerDelegate {
    func interstitialHandler(_ handler: InterstitialHandler,
                             willPresentInterstitial interstitial: GADInterstitial) {
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
