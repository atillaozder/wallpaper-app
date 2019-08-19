//
//  EncoderError.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation

enum EncoderError: String, Error {
    case missingParameters  = "Parameters was nil."
    case encodingFailed     = "Parameter encoding was failed."
    case missingURL         = "URL was nil."
}
