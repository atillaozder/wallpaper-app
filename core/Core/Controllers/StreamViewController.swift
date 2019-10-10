//
//  StreamViewController.swift
//  Core
//
//  Created by Atilla Özder on 10.10.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import GoogleMobileAds

class StreamViewController: ImageListViewController {
    
    private weak var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        InterstitialHandler.shared().increase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timer = Timer.scheduledTimer(
            timeInterval: 15,
            target: self,
            selector: #selector(refreshData),
            userInfo: nil,
            repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    override func setupViews() {
        super.setupViews()
        self.navigationItem.title = Localization.stream
    }
    
    @objc
    private func refreshData() {
        viewModel.load()
    }
}
