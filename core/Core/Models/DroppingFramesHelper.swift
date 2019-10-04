//
//  DroppingFramesHelper.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

public class DroppingFramesHelper {
    var firstTime: TimeInterval = 0
    var lastTime: TimeInterval = 0
    
    public init() {}
    
    public func activate() {
        let link = CADisplayLink(target: self, selector: #selector(update(_:)))
        link.add(to: .main, forMode: .common)
    }
    
    @objc
    private func update(_ link: CADisplayLink) {
        if lastTime == 0 {
            firstTime = link.timestamp
            lastTime = link.timestamp
        }
        
        let currentTime = link.timestamp
        let totalElapsedTime = currentTime - firstTime
        let elapsedTime = floor((currentTime - lastTime) * 10_000) / 10
        
        if elapsedTime > 16.7 {
            print("Frame was dropped with elapsed time \(elapsedTime)ms at \(totalElapsedTime)")
        }
        
        lastTime = link.timestamp
    }
}
