//
//  Client.swift
//  manuege
//
//  Created by Manu on 15/2/16.
//  Copyright © 2016 manuege. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire
import Raccoon

// MARK: Base

public class Client {
    
    public let baseURL: String
    public let context: InsertContext
    public let responseConverter: ResponseConverter?
    
    
    public init(baseURL: String, context: InsertContext, responseConverter: ResponseConverter? = nil) {
        self.baseURL = baseURL
        self.context = context
        self.responseConverter = responseConverter
    }

    
    public func request<T: Insertable>(request: Request, type: T.Type) -> Promise<T> {
        return Promise<T>(resolvers: { (fulfill, reject) -> Void in
            request.response(T.self, context: context, converter: responseConverter, completionHandler: { (response) -> Void in
                switch response.result {
                case .Success(let value):
                    fulfill(value)
                case .Failure(let error):
                    reject(error)
                }
            })
        })
    }
    
    public func request<T: Insertable>(request: Request, type: [T].Type) -> Promise<[T]> {
        
        return Promise<[T]>(resolvers: { (fulfill, reject) -> Void in
            request.response([T].self, context: context, converter: responseConverter, completionHandler: { (response) -> Void in
                
                switch response.result {
                case .Success(let value):
                    fulfill(value)
                case .Failure(let error):
                    reject(error)
                }
            })
        })
    }
    
    public func request<T: Wrapper>(request: Request,  type: T.Type) -> Promise<T> {
        return Promise<T>(resolvers: { (fulfill, reject) -> Void in
            request.response(T.self, context: context, converter: responseConverter, completionHandler: { (response) -> Void in
                
                switch response.result {
                case .Success(let value):
                    fulfill(value)
                case .Failure(let error):
                    reject(error)
                }
            })
        })
    }
    
    public func request(request: Request) -> Promise<Void> {
        request.response
        return Promise<Void>(resolvers: { (fulfill, reject) -> Void in
            request.emptyResponse(responseConverter, completionHandler: { (response) in
                switch response {
                case .Success:
                    fulfill()
                case .Failure(let error):
                    reject(error)
                }
            })
        })
    }
}

// MARK: URLRequestConvertible
extension Client {
    
    public func request<T: Insertable>(requestConvertible: URLRequestConvertible, type: T.Type) -> Promise<T> {
        return request(Alamofire.request(requestConvertible), type: T.self)
    }
    
    public func request<T: Insertable>(requestConvertible: URLRequestConvertible, type: [T].Type) -> Promise<[T]> {
        return request(Alamofire.request(requestConvertible), type: [T].self)
    }
    
    public func request<T: Wrapper>(requestConvertible: URLRequestConvertible, type: T.Type) -> Promise<T> {
        return request(Alamofire.request(requestConvertible), type: T.self)
    }
    
    public func request(requestConvertible: URLRequestConvertible) -> Promise<Void> {
        return request(Alamofire.request(requestConvertible))
    }
}

// MARK: Endpoint
extension Client {
    
    public func request<T: Insertable>(endpointConvertible: EndpointConvertible, type: T.Type) -> Promise<T> {
        return request(endpointConvertible.endpoint.request(withBaseURL: baseURL), type: T.self)
    }
    
    public func request<T: Insertable>(endpointConvertible: EndpointConvertible, type: [T].Type) -> Promise<[T]> {
        return request(endpointConvertible.endpoint.request(withBaseURL: baseURL), type: [T].self)
    }
    
    public func request<T: Wrapper>(endpointConvertible: EndpointConvertible, type: T.Type) -> Promise<T> {
        return request(endpointConvertible.endpoint.request(withBaseURL: baseURL), type: T.self)
    }
    
    public func request(endpointConvertible: EndpointConvertible) -> Promise<Void> {
        return request(endpointConvertible.endpoint.request(withBaseURL: baseURL))
    }
}
