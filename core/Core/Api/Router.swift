//
//  Router.swift
//  Core
//
//  Created by Atilla Özder on 4.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation
import Alamofire

enum Router {
    case recent(page: Int)
    case category(page: Int)
    case categoryItems(categoryId: Int, page: Int)
}

extension Router: URLRequestConfigurable {
    var baseURL: URL? {
        return URL(string: ApiConstants.baseURLString + "api/")
    }
    
    var path: String {
        
        var gameName: String = ""
        do {
            let appPList = try PListFile<InfoPList>()
            gameName = appPList.data.configuration.gameName
        } catch let err {
            #if DEBUG
            print("Failed to parse data: \(err.localizedDescription)")
            #endif
        }
        
        switch self {
        case .recent:
            return "v1/core/\(gameName)/recent"
        case .category:
            return "v1/core/\(gameName)/category"
        case .categoryItems(let categoryId, _):
            return "v1/core/\(gameName)/category/\(categoryId)"
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var urlParameters: Parameters? {
        switch self {
        case .recent(let page), .category(let page), .categoryItems(_, let page):
            return ["page": page]
        }
    }
    
    var bodyParameters: Parameters? {
        return nil
    }
    
    var bodyParameterEncoding: BodyParameterEncoding {
        return .jsonEncoding
    }
    
    var headers: HTTPHeaders? {
        return HTTPHeaders(arrayLiteral: .contentType("application/json"))
    }
    
    func asURLRequest() throws -> URLRequest {
        guard let url = self.baseURL?.appendingPathComponent(path) else {
            throw EncoderError.missingURL
        }
        
        var urlRequest = URLRequest(url: url)
        try configure(urlRequest: &urlRequest)
        return urlRequest
    }
}
