//
//  Error+Conversion.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation

extension Error {
    /// Returns the instance cast as an `ApiError`.
    var asApiError: ApiError {
        return (self as? ApiError) ?? .requestFailed
    }
}
