//
//  ViewState.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation

enum ViewState: Equatable {
    case loaded
    case error(_ error: ApiError)
    case noData
    
    static func == (lhs: ViewState, rhs: ViewState) -> Bool {
        switch (lhs, rhs) {
        case (.loaded, .loaded):
            return true
        case (.noData, .noData):
            return true
        case (.error, .error):
            return true
        default:
            return false
        }
    }
}
