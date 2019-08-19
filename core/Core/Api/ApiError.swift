//
//  ApiError.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation

enum ApiError: Swift.Error, CustomStringConvertible {
    case requestFailed
    case invalidData
    case responseUnsuccessfull
    case jsonSerializationFailure
    case jsonCastingFailure
    case jsonDecodingFailure
    case jsonEncodingFailure
    case forbidden
    case immediateLogout
    case notFound
    case errorCastingFailure(data: Data)
    case unAuthorized(response: ApiErrorResponse)
    case apiFailure(err: ApiErrorResponse)
    case imageUploadFailure(resp: String)
    
    var description: String {
        switch self {
        case .invalidData: return "Invalid Data"
        case .requestFailed: return "Request Failed"
        case .responseUnsuccessfull: return "Response Unsuccessfull"
        case .immediateLogout: return "403 or 401, Logout Immediately"
        case .notFound: return "404, Not Found"
        case .jsonDecodingFailure: return "JSON Decoding Failure"
        case .jsonEncodingFailure: return "JSON Encoding Failure"
        case .jsonSerializationFailure: return "JSON Serialization Failure"
        case .jsonCastingFailure: return "JSON Casting Failure"
        case .forbidden: return "Forbidden"
        case .errorCastingFailure: return "Cast Failure, create an error object"
        case .unAuthorized: return "Unauthorized"
        case .apiFailure(let resp): return "Api Error \(resp.error) - code: \(resp.errorCode ?? -000) - description: \(resp.errorDesc ?? "")"
        case .imageUploadFailure: return "Image Upload Failure"
        }
    }
}
