//
//  LoggableService.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation
import Alamofire

protocol LoggableService {
    func debugLog()
}

extension DataRequest: LoggableService {
    @objc
    func debugLog() {
        #if DEBUG
        print("===================================== \n")
        print(self.cURLDescription() + "\n")
        print("===================================== \n")
        #endif
    }
}

extension UploadRequest {
    @objc
    override func debugLog() {
        #if DEBUG
        self.uploadProgress(
            queue: DispatchQueue.global(qos: .background),
            closure: { (progress) in
                print("%\(Int(progress.fractionCompleted * 100))")
        }
        )
        #endif
    }
}

extension DataResponse: LoggableService {
    func debugLog() {
        #if DEBUG
        if let metrics = self.metrics {
            print("Duration: \(metrics.taskInterval.duration)")
        }
        #endif
    }
}
