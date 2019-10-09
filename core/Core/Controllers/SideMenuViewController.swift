//
//  SideMenuViewController.swift
//  Core
//
//  Created by Atilla Özder on 16.09.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation

struct SideMenuButtonFactory {
    func generateButton() -> UIButton {
        let btn = UIButton(type: .custom)
        btn.contentEdgeInsets = .init(top: 16, left: 0, bottom: 16, right: 0)
        btn.titleEdgeInsets.left = 16
        btn.backgroundColor = .darkTheme
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.contentHorizontalAlignment = .left
        btn.contentVerticalAlignment = .center
        btn.tintColor = .white
        btn.imageView?.contentMode = .center
        btn.tintAdjustmentMode = .normal
        btn.adjustsImageWhenHighlighted = false
        btn.adjustsImageWhenDisabled = false
        return btn
    }
}

enum HomePageMenu: Int {
    case recent = 0
    case category = 1
    case random = 2
    case favorites = 3
}

protocol SideMenuViewControllerDelegate: class {
    func sideMenuViewController(_ viewController: SideMenuViewController, didSelectPageMenu pageMenu: HomePageMenu)
}

class SideMenuViewController: UIViewController {
    
    weak var delegate: SideMenuViewControllerDelegate?
    
    lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.bounces = true
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        sv.backgroundColor = .darkTheme
        sv.isScrollEnabled = true
        return sv
    }()
    
    lazy var contentView: UIView = {
        let v = UIView()
        v.backgroundColor = .darkTheme
        return v
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView(image: Asset.icLogo.image)
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = .imageBackground
        return iv
    }()
    
    let appNameLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = Bundle.main.displayName
        lbl.font = UIFont.systemFont(ofSize: 16)
        lbl.textColor = .white
        lbl.textAlignment = .left
        return lbl
    }()
    
    let descriptionLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "High Definition Wallpapers"
        lbl.font = UIFont.systemFont(ofSize: 13)
        lbl.textColor = .white
        lbl.textAlignment = .left
        return lbl
    }()
    
    lazy var recentButton: UIButton = {
        let btn = SideMenuButtonFactory().generateButton()
        btn.setTitle(Localization.recent.capitalized(with: .current), for: .normal)
        btn.setImage(Asset.icRecent.image.resize(to: .init(width: 24, height: 24)).withRenderingMode(.alwaysTemplate), for: .normal)
        btn.addTarget(self, action: #selector(recentTapped), for: .touchUpInside)
        return btn
    }()
    
    lazy var categoryButton: UIButton = {
        let btn = SideMenuButtonFactory().generateButton()
        btn.setTitle(Localization.category.capitalized(with: .current), for: .normal)
        btn.setImage(Asset.icCategory.image.resize(to: .init(width: 24, height: 24)).withRenderingMode(.alwaysTemplate), for: .normal)
        btn.addTarget(self, action: #selector(categoryTapped), for: .touchUpInside)
        return btn
    }()
    
    lazy var randomButton: UIButton = {
        let btn = SideMenuButtonFactory().generateButton()
        btn.setTitle(Localization.random.capitalized(with: .current), for: .normal)
        btn.setImage(Asset.icRandom.image.resize(to: .init(width: 24, height: 24)).withRenderingMode(.alwaysTemplate), for: .normal)
        btn.addTarget(self, action: #selector(randomTapped), for: .touchUpInside)
        return btn
    }()
    
    lazy var favoritesButton: UIButton = {
        let btn = SideMenuButtonFactory().generateButton()
        btn.setTitle(Localization.favorites.capitalized(with: .current), for: .normal)
        btn.setImage(Asset.icHeart.image.resize(to: .init(width: 24, height: 24)).withRenderingMode(.alwaysTemplate), for: .normal)
        btn.addTarget(self, action: #selector(favoritesTapped), for: .touchUpInside)
        return btn
    }()
    
    lazy var privacyPolicyButton: UIButton = {
        let btn = SideMenuButtonFactory().generateButton()
        btn.setTitle("Privacy Policy", for: .normal)
        btn.setImage(Asset.icPrivacyPolicy.image.resize(to: .init(width: 24, height: 24)).withRenderingMode(.alwaysTemplate), for: .normal)
        btn.addTarget(self, action: #selector(privacyPolicyTapped), for: .touchUpInside)
        return btn
    }()
    
    lazy var shareButton: UIButton = {
        let btn = SideMenuButtonFactory().generateButton()
        btn.setTitle(Localization.share.capitalized(with: .current), for: .normal)
        btn.setImage(Asset.icUpload.image.resize(to: .init(width: 24, height: 24)).withRenderingMode(.alwaysTemplate), for: .normal)
        btn.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        return btn
    }()
    
    lazy var moreAppButton: UIButton = {
        let btn = SideMenuButtonFactory().generateButton()
        btn.setTitle("More App", for: .normal)
        btn.setImage(Asset.icMoreApp.image.resize(to: .init(width: 24, height: 24)).withRenderingMode(.alwaysTemplate), for: .normal)
        btn.addTarget(self, action: #selector(moreAppTapped), for: .touchUpInside)
        return btn
    }()
    
    lazy var rateUsButton: UIButton = {
        let btn = SideMenuButtonFactory().generateButton()
        btn.setTitle("Rate Us", for: .normal)
        btn.setImage(Asset.icEmptyStar.image.resize(to: .init(width: 24, height: 24)).withRenderingMode(.alwaysTemplate), for: .normal)
        btn.addTarget(self, action: #selector(rateUsTapped), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var frame = CGRect.zero
        for view in contentView.subviews {
            frame = frame.union(view.frame)
        }
        frame.size.height += 16
        let height = max(frame.size.height, view.bounds.height)
        contentViewHeightConstraint?.constant = height
        scrollView.contentSize = .init(width: scrollView.bounds.width, height: height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        view.backgroundColor = .darkTheme
        setupScrollView()
        setupAppInfo()
        
        let vSeparator = UIView()
        vSeparator.backgroundColor = .white
        vSeparator.pinHeight(to: 1)
        contentView.addSubview(vSeparator)
        vSeparator.pinEdgesToView(contentView, exclude: [.top, .bottom])
        vSeparator.pinTop(to: descriptionLabel.bottomAnchor, constant: 24)
        
        let stackView = UIStackView(arrangedSubviews: [recentButton, categoryButton, randomButton, favoritesButton])
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.isUserInteractionEnabled = true
        
        contentView.addSubview(stackView)
        stackView.pinTop(to: vSeparator.bottomAnchor, constant: 8)
        stackView.pinLeading(to: imageView.leadingAnchor)
        stackView.pinTrailing(to: contentView.trailingAnchor)
        
        let vSeparator2 = UIView()
        vSeparator2.backgroundColor = .white
        vSeparator2.pinHeight(to: 1)
        contentView.addSubview(vSeparator2)
        vSeparator2.pinEdgesToView(contentView, exclude: [.top, .bottom])
        vSeparator2.pinTop(to: stackView.bottomAnchor, constant: 8)
        
        let bottomVStack = UIStackView(arrangedSubviews: [rateUsButton, shareButton, moreAppButton, privacyPolicyButton])
        bottomVStack.axis = .vertical
        bottomVStack.spacing = 0
        bottomVStack.distribution = .fillEqually
        bottomVStack.alignment = .fill
        bottomVStack.isUserInteractionEnabled = true

        contentView.addSubview(bottomVStack)
        bottomVStack.pinTop(to: vSeparator2.bottomAnchor, constant: 8)
        bottomVStack.pinLeading(to: imageView.leadingAnchor)
        bottomVStack.pinTrailing(to: contentView.trailingAnchor)
    }
    
    var contentViewHeightConstraint: NSLayoutConstraint?
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.pinEdgesUnSafeArea()
        scrollView.addSubview(contentView)
        contentView.pinEdgesUnSafeArea()
        contentView.pinWidth(to: scrollView.widthAnchor)
        contentViewHeightConstraint = contentView.pinHeight(to: UIScreen.main.bounds.height)
    }
    
    private func setupAppInfo() {
        contentView.addSubview(imageView)
        imageView.pinTop(to: contentView.topAnchor)
        imageView.pinLeading(to: contentView.leadingAnchor, constant: 16)
        imageView.pin(size: .init(width: 60, height: 60))
        
        contentView.addSubview(appNameLabel)
        appNameLabel.pinTop(to: imageView.bottomAnchor, constant: 24)
        appNameLabel.pinLeading(to: imageView.leadingAnchor, constant: 0)
        
        contentView.addSubview(descriptionLabel)
        descriptionLabel.pinTop(to: appNameLabel.bottomAnchor, constant: 4)
        descriptionLabel.pinLeading(to: imageView.leadingAnchor, constant: 0)
    }
    
    @objc
    func favoritesTapped() {
        dismiss(animated: true, completion: nil)
        delegate?.sideMenuViewController(self, didSelectPageMenu: .favorites)
    }
    
    @objc
    func recentTapped() {
        dismiss(animated: true, completion: nil)
        delegate?.sideMenuViewController(self, didSelectPageMenu: .recent)
    }
    
    @objc
    func randomTapped() {
        dismiss(animated: true, completion: nil)
        delegate?.sideMenuViewController(self, didSelectPageMenu: .random)
    }
    
    @objc
    func categoryTapped() {
        dismiss(animated: true, completion: nil)
        delegate?.sideMenuViewController(self, didSelectPageMenu: .category)
    }
        
    @objc
    func moreAppTapped() {
        if let url = URL(string: "https://apps.apple.com/tr/developer/atilla-ozder/id1440770128") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc
    func shareTapped() {
        if let url = URL(string: "https://apps.apple.com/tr/developer/atilla-ozder/id1440770128") {
            let viewController = UIActivityViewController(
                activityItems: [url],
                applicationActivities: nil)
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    @objc
    func privacyPolicyTapped() {
        if let url = ApiConstants.privacyPolicyURLString.asURL() {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc
    func rateUsTapped() {
        // StoreReviewHelper().requestReview()
        let urlString = "https://itunes.apple.com/app/id\(1481404298)?action=write-review"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
