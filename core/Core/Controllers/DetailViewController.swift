//
//  DetailViewController.swift
//  Core
//
//  Created by Atilla Özder on 10.10.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import RxSwift
import Photos
import CropViewController
import GoogleMobileAds
import SDWebImage
import FMPhotoPicker

class DetailViewController: UIViewController {
    
    private let bag: DisposeBag = DisposeBag()
    private let viewModel: DetailViewModel
    
    unowned var favBtn: UIButton { return buttonBar.favoriteButton }
    lazy var buttonBar: ImageActionBar = {
        return ImageActionBar()
    }()
        
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        layout.sectionInset = .zero
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .darkTheme
        cv.registerCell(DetailCell.self)
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.bounces = false
        cv.dataSource = self
        cv.delegate = self
        cv.isPagingEnabled = true
        return cv
    }()
    
    lazy var bannerView: GADBannerView = {
        return getBannerView()
    }()
    
    init(images: [ImageCellViewModel], startFrom item: Int) {
        self.viewModel = DetailViewModel(images: images, startFrom: item)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.viewModel = DetailViewModel(images: [], startFrom: 0)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        InterstitialHandler.shared().setDelegate(self)
        view.backgroundColor = .darkTheme
                
        view.addSubview(collectionView)
        collectionView.pinEdgesToSuperview()
                
        view.addSubview(bannerView)
        bannerView.pinCenterX(to: view.centerXAnchor)
        bannerView.pinBottom(to: view.safeBottomAnchor)

        setupButtons()
        
        let ip = viewModel.indexPath
        self.navigationItem.title = viewModel.navigationItemTitle
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: ip, at: .centeredHorizontally, animated: false)
            if let cell = self.collectionView.visibleCells.first {
                self.collectionView(self.collectionView, willDisplay: cell, forItemAt: ip)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bannerView.delegate = self
    }
    
    private func setupButtons() {
        favBtn.addTarget(self,
                         action: #selector(favoriteTapped),
                         for: .touchUpInside)
        
        buttonBar
            .shareButton
            .addTarget(self,
                       action: #selector(shareTapped),
                       for: .touchUpInside)
        
        buttonBar
            .editButton
            .addTarget(self,
                       action: #selector(editTapped),
                       for: .touchUpInside)
        
        buttonBar
            .downloadButton
            .addTarget(self,
                       action: #selector(downloadTapped),
                       for: .touchUpInside)
        
        buttonBar
            .previewButton
            .addTarget(self,
                       action: #selector(previewTapped),
                       for: .touchUpInside)
                
        view.insertSubview(buttonBar, at: 1)
        buttonBar.pinEdgesToView(view, insets: .zero, exclude: [.top, .bottom])
        buttonBar.buttonBarBottomConstraint = buttonBar.pinBottom(to: view.safeBottomAnchor)
        buttonBar.pinHeight(to: ImageActionBar.defaultHeight)
        view.bringSubviewToFront(buttonBar)
    }
    
    @objc
    func shareTapped() {
        InterstitialHandler.shared().increase()
        guard let image = viewModel.uiImage()?.jpegData(compressionQuality: 1.0) else { return }
        let viewController = UIActivityViewController(activityItems: [image], applicationActivities: [])
        viewController.excludedActivityTypes = [.saveToCameraRoll]
        viewController.popoverPresentationController?.sourceView = self.view
        self.present(viewController, animated: true, completion: nil)
    }
    
    @objc
    func editTapped() {
        if let image = viewModel.uiImage() {
            let editor = FMImageEditorViewController(config: .init(), sourceImage: image)
            editor.delegate = self
            self.present(editor, animated: true)
        }
    }
    
    @objc
    func previewTapped() {
        getLibraryPermission { [weak self] (authorized) in
            guard let `self` = self else { return }
            authorized ? self.presentCropController() : self.askPermission()
        }
    }
    
    @objc
    func favoriteTapped() {
        let newValue = !StorageHelper.shared().value(for: viewModel.image())
        viewModel.toggleFavorite()
        buttonBar.isFavorited = newValue
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
        if let image = viewModel.uiImage() {
            let cropController = CropViewController(croppingStyle: .default, image: image)
            cropController.aspectRatioPreset = .presetCustom
            cropController.aspectRatioPickerButtonHidden = false
            cropController.delegate = self
            cropController.showActivitySheetOnDone = true
            cropController.toolbarPosition = .top
            cropController.toolbar.statusBarHeightInset = UIApplication.shared.statusBarFrame.height
            self.navigationController?.pushViewController(cropController, animated: true)
        }
    }
    
    private func saveImage() {
        viewModel.save() { [weak self] (success, error) in
            guard let `self` = self else { return }
            if success {
                InterstitialHandler.shared().increase()
                DispatchQueue.main.async {
                    let inset = ImageActionBar.defaultHeight + self.bannerView.frame.height
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
}

extension DetailViewController: GADBannerViewDelegate {
    // Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        var insets = UIEdgeInsets.zero
        insets.bottom += bannerView.frame.height
        insets.bottom += view.windowSafeAreaInsets.bottom
        
        if let cell = collectionView.visibleCells.first as? DetailCell {
            cell.scrollView.contentInset = insets
        }
        
        if !viewModel.didReceiveAd {
            buttonBar.buttonBarBottomConstraint?.constant -= bannerView.frame.height
            viewModel.didReceiveAd = true
        }
    }
}

extension DetailViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return viewModel.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath) as DetailCell
        let cvm = viewModel.cellViewModel(at: indexPath)
        cell.bind(to: cvm)
        return cell
    }
}

extension DetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        viewModel.indexPath = indexPath
        buttonBar.isFavorited = StorageHelper.shared().value(for: viewModel.image())
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        InterstitialHandler.shared().increase()
        navigationItem.title = viewModel.navigationItemTitle
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = collectionView.frame.size
        size.height -= ImageActionBar.defaultHeight
        size.height -= collectionView.contentInset.bottom
        return size
    }
}

extension DetailViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController,
                            didFinishCancelled cancelled: Bool) {
        self.navigationController?.popViewController(animated: true)
        if !cancelled {
            InterstitialHandler.shared().triggerPresentingInterstitial()
        }
    }
}

extension DetailViewController: InterstitialHandlerDelegate {
    func interstitialHandler(_ handler: InterstitialHandler,
                             willPresentInterstitial interstitial: GADInterstitial) {
        interstitial.present(fromRootViewController: self)
    }
}

extension DetailViewController: FMImageEditorViewControllerDelegate {
    func fmImageEditorViewController(_ editor: FMImageEditorViewController,
                                     didFinishEdittingPhotoWith photo: UIImage) {
        viewModel.setImage(photo)
        editor.dismiss(animated: true, completion: nil)
    }
}
