//
//  ApiErrorResponse.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation

struct ApiErrorResponse {
    var error: String
    var errorDesc: String?
    var errorCode: Int?
}

extension ApiErrorResponse: Decodable {
    private enum CodingKeys: String, CodingKey {
        case error
        case errorDesc = "error_description"
        case errorCode = "error_code"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        error = try container.decode(String.self, forKey: .error)
        errorDesc = try container.decodeIfPresent(String.self, forKey: .errorDesc)
        
        if let code = try container.decodeIfPresent(Int.self, forKey: .errorCode) {
            errorCode = code
        } else {
            if let codeDesc = try container.decodeIfPresent(String.self, forKey: .errorCode) {
                errorCode = Int(codeDesc)
            }
        }
    }
}
