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
    
    public let context: InsertContext
    public let endpointSerializer: EndpointSerializer?
    public let responseConverter: ResponseConverter?
    
    public init(context: InsertContext, endpointSerializer: EndpointSerializer? = nil, responseConverter: ResponseConverter? = nil) {
        self.context = context
        self.endpointSerializer = endpointSerializer
        self.responseConverter = responseConverter
    }
    
    public convenience init(context: InsertContext, baseURL: String, responseConverter: ResponseConverter? = nil) {
        
        let endpointSerializer: EndpointSerializer = { (endpoint) -> (Request) in
            let headers = endpoint.headers
            
            var path = endpoint.path
            if !endpoint.path.hasPrefix("/") {
                path = "/\(path)"
            }
            
            let request = Alamofire.request(endpoint.method,
                                            "\(baseURL)\(path)",
                                            parameters: endpoint.parameters,
                                            encoding: endpoint.encoding,
                                            headers: headers)
            
            return request.validate()
        }
        
        self.init(context: context, endpointSerializer: endpointSerializer, responseConverter: responseConverter)
    }
    
    public func enqueue<T: Insertable>(request: Request, type: T.Type) -> Promise<T> {
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
    
    public func enqueue<T: Insertable>(request: Request, type: [T].Type) -> Promise<[T]> {
        
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
    
    public func enqueue<T: Wrapper>(request: Request,  type: T.Type) -> Promise<T> {
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
    
    public func enqueue(request: Request) -> Promise<Void> {
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
    
    public func enqueue<T: Insertable>(requestConvertible: URLRequestConvertible, type: T.Type) -> Promise<T> {
        return enqueue(request(requestConvertible), type: T.self)
    }
    
    public func enqueue<T: Insertable>(requestConvertible: URLRequestConvertible, type: [T].Type) -> Promise<[T]> {
        return enqueue(request(requestConvertible), type: [T].self)
    }
    
    public func enqueue<T: Wrapper>(requestConvertible: URLRequestConvertible, type: T.Type) -> Promise<T> {
        return enqueue(request(requestConvertible), type: T.self)
    }
    
    public func enqueue(requestConvertible: URLRequestConvertible) -> Promise<Void> {
        return enqueue(request(requestConvertible))
    }
}

// MARK: Endpoint
extension Client {
    
    public func enqueue<T: Insertable>(endpointConvertible: EndpointConvertible, type: T.Type) -> Promise<T> {
        return enqueue(endpointSerializer!(endpointConvertible.endpoint), type: T.self)
    }
    
    public func enqueue<T: Insertable>(endpointConvertible: EndpointConvertible, type: [T].Type) -> Promise<[T]> {
        return enqueue(endpointSerializer!(endpointConvertible.endpoint), type: [T].self)
    }
    
    public func enqueue<T: Wrapper>(endpointConvertible: EndpointConvertible, type: T.Type) -> Promise<T> {
        return enqueue(endpointSerializer!(endpointConvertible.endpoint), type: T.self)
    }
    
    public func enqueue(endpointConvertible: EndpointConvertible) -> Promise<Void> {
        return enqueue(endpointSerializer!(endpointConvertible.endpoint))
    }
}
