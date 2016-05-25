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
class Client {
    
    var context: InsertContext
    var endpointSerializer: EndpointSerializer?
    
    init(context: InsertContext, endpointSerializer: EndpointSerializer?) {
        self.context = context
        self.endpointSerializer = endpointSerializer
    }
    
    convenience init(context: InsertContext, baseURL: String) {
        self.init(context: context) { (endpoint) -> (Request) in
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
    }
    
    func enqueue<T: Insertable>(request: Request) -> Promise<T> {
        return Promise<T>(resolvers: { (fulfill, reject) -> Void in
            request.response(context, completionHandler: { (response: Response<T, NSError>) -> Void in
                switch response.result {
                case .Success(let value):
                    fulfill(value)
                case .Failure(let error):
                    reject(error)
                }
            })
        })
    }
    
    func enqueue<T: Insertable>(request: Request) -> Promise<[T]> {
        
        return Promise<[T]>(resolvers: { (fulfill, reject) -> Void in
            request.response(context, completionHandler: { (response: Response<[T], NSError>) -> Void in
                
                switch response.result {
                case .Success(let value):
                    fulfill(value)
                case .Failure(let error):
                    reject(error)
                }
            })
        })
    }
    
    func enqueue<T: Wrapper>(request: Request) -> Promise<T> {
        return Promise<T>(resolvers: { (fulfill, reject) -> Void in
            request.response(context, completionHandler: { (response: Response<T, NSError>) -> Void in
                
                switch response.result {
                case .Success(let value):
                    fulfill(value)
                case .Failure(let error):
                    reject(error)
                }
            })
        })
    }
    
    func enqueue(request: Request) -> Promise<Void> {
        return Promise<Void>(resolvers: { (fulfill, reject) -> Void in
            request.responseData(completionHandler: { (response: Response<NSData, NSError>) in
                switch response.result {
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
    
    func enqueue<T: Insertable>(requestConvertible: URLRequestConvertible) -> Promise<T> {
        return enqueue(request(requestConvertible))
    }
    
    func enqueue<T: Insertable>(requestConvertible: URLRequestConvertible) -> Promise<[T]> {
        return enqueue(request(requestConvertible))
    }
    
    func enqueue<T: Wrapper>(requestConvertible: URLRequestConvertible) -> Promise<T> {
        return enqueue(request(requestConvertible))
    }
    
    func enqueue(requestConvertible: URLRequestConvertible) -> Promise<Void> {
        return enqueue(request(requestConvertible))
    }
}

// MARK: Endpoint
extension Client {
    
    func enqueue<T: Insertable>(endpointConvertible: EndpointConvertible) -> Promise<T> {
        return enqueue(endpointSerializer!(endpointConvertible.endpoint))
    }
    
    func enqueue<T: Insertable>(endpointConvertible: EndpointConvertible) -> Promise<[T]> {
        return enqueue(endpointSerializer!(endpointConvertible.endpoint))
    }
    
    func enqueue<T: Wrapper>(endpointConvertible: EndpointConvertible) -> Promise<T> {
        return enqueue(endpointSerializer!(endpointConvertible.endpoint))
    }
    
    func enqueue(endpointConvertible: EndpointConvertible) -> Promise<Void> {
        return enqueue(endpointSerializer!(endpointConvertible.endpoint))
    }
}
