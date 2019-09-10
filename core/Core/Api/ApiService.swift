//
//  ApiService.swift
//  Core
//
//  Created by Atilla Özder on 2.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

typealias JSON = [String: Any]

final class ApiService {
    
    private static let instance = ApiService()
    private let session: Session
    private var dataRequest: DataRequest?
    
    static func shared() -> ApiService {
        return ApiService.instance
    }
    
    private init() {
        let configuration = URLSessionConfiguration.af.default
        if #available(iOS 11, *) {
            configuration.waitsForConnectivity = true
        }
        
        self.session = Session(configuration: configuration)
    }
    
    func cancel() {
        self.dataRequest?.cancel()
    }
    
    func request<T: Decodable>(
        _ urlReq: URLRequestConvertible,
        type: T.Type) -> Observable<T>
    {
        
        return Observable<T>.create { [weak self] observer in
            guard let `self` = self else {
                return Disposables.create()
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(.iso8601Full)
            
            self.dataRequest = self.session.request(urlReq)
                .responseDecodable(queue: self.session.requestQueue,
                                   decoder: decoder)
                { [weak self] (dataResp: DataResponse<T, AFError>) in
                    
                    self?.dataRequest?.debugLog()
                    dataResp.debugLog()
                    
                    if let apiError = dataResp.checkError() {
                        observer.onError(apiError)
                    } else if let err = dataResp.error {
                        observer.onError(err)
                    }
                    
                    if let obj = dataResp.value {
                        observer.onNext(obj)
                        observer.onCompleted()
                    } else {
                        observer.onError(ApiError.jsonDecodingFailure)
                    }
            }
            
            return Disposables.create()
        }
    }
    
    func requestJson(_ urlReq: URLRequestConvertible) -> Observable<JSON> {
        return Observable<JSON>.create { [weak self] observer in
            guard let `self` = self else {
                return Disposables.create()
            }
            
            let JSONSerializer = JSONResponseSerializer(
                dataPreprocessor: PassthroughPreprocessor(),
                emptyResponseCodes: Set(arrayLiteral: 204, 205),
                emptyRequestMethods: Set(arrayLiteral: .head, .post, .put, .patch, .get),
                options: .allowFragments)
            
            self.dataRequest = self.session.request(urlReq)
                .response(queue: self.session.requestQueue,
                          responseSerializer: JSONSerializer)
                { [weak self] (dataResp) in
                    
                    self?.dataRequest?.debugLog()
                    dataResp.debugLog()
                    
                    if let apiError = dataResp.checkError() {
                        observer.onError(apiError)
                    } else if let err = dataResp.error {
                        observer.onError(err)
                    }
                    
                    do {
                        let jsonObj = try dataResp.jsonValue()
                        observer.onNext(jsonObj)
                        observer.onCompleted()
                    } catch {
                        observer.onError(error)
                    }
            }
            
            return Disposables.create()
        }
    }
}

extension DataResponse {
    func jsonValue() throws -> JSON {
        guard let val = value else { return [:] }
        
        if val is NSNull {
            return [:]
        }
        
        if let obj = value as? JSON {
            return obj
        } else {
            throw ApiError.jsonCastingFailure
        }
    }
    
    func checkError() -> ApiError? {
        guard let code = self.response?.statusCode else { return nil }
        
        switch code {
        case 200...299:
            return nil
        case 400:
            guard let data = self.data else { return .invalidData }
            do {
                let errObj = try JSONDecoder().decode(ApiErrorResponse.self, from: data)
                return .apiFailure(err: errObj)
            } catch {
                return .errorCastingFailure(data: data)
            }
        case 404:
            return .notFound
        default:
            guard let data = self.data else { return .invalidData }
            return .errorCastingFailure(data: data)
        }
    }
}
