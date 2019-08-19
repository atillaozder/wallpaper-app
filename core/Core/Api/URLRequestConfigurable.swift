//
//  URLRequestConfigurable.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation
import Alamofire

protocol URLRequestConfigurable: URLRequestConvertible {
    var baseURL: URL? { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var urlParameters: Parameters? { get }
    var bodyParameters: Parameters? { get }
    var bodyParameterEncoding: BodyParameterEncoding { get }
    var headers: HTTPHeaders? { get }
}

extension URLRequestConfigurable {
    
    func configure(urlRequest: inout URLRequest) throws {
        urlRequest.httpMethod = self.method.rawValue
        
        if var headers = self.headers {
            headers.add(.init(name: "Accept", value: "application/json"))
            urlRequest.headers = headers
        }
        
        urlRequest = try URLEncoding(destination: .queryString, arrayEncoding: .noBrackets, boolEncoding: .literal).encode(urlRequest, with: urlParameters)
        
        switch bodyParameterEncoding {
        case .jsonEncoding:
            urlRequest = try JSONEncoding(options: .prettyPrinted).encode(urlRequest, with: bodyParameters)
        case .formUrlEncoding:
            urlRequest = try URLEncoding(destination: .httpBody, arrayEncoding: .brackets, boolEncoding: .literal).encode(urlRequest, with: bodyParameters)
        }
    }
}
