//
//  Client.swift
//  raccoon
//
//  Created by Manuel García-Estañ on 8/10/16.
//  Copyright © 2016 manuege. All rights reserved.
//

import Foundation
import CoreData
import Alamofire
import AlamofireCoreData
import PromiseKit

/// Clients are instances that can send request builts using `Endpoints`. 
/// The responses of this endpoints will be inserted in the given managed object context.
protocol Client {
    
    // MARK: Required
    /// The base url which will be used to build the reqeusts
    var baseURL: String { get }
    
    /// The managed object context where all the responses will be inserted.
    var context: NSManagedObjectContext { get }
    
    // MARK: Optionals
    /// The DataResponseSerializer<Any> which will transform the original response to the JSON which will be used to insert the responses. 
    /// By default it is `DataRequest.jsonResponseSerializer()`
    var jsonSerialier: DataResponseSerializer<Any> { get }
    

    ///
    /// Use this method to perform any last minute changes on the DataRequest to send.
    /// Here you can add some validations, log the requests, or whatever thing you need.
    /// By default, it returns the request itself, without any addition
    ///
    /// - parameter request: the request that will be sent
    ///
    /// - returns: the modified request
    func prepare(_ request: DataRequest) -> DataRequest
}

extension Client {
    
    var jsonSerializer: DataResponseSerializer<Any> {
        return DataRequest.jsonResponseSerializer()
    }
    
    func prepare(_ request: DataRequest) -> DataRequest {
        return request
    }
}

extension Client {
    
    
    /// Enqueues the request generated by the endpoint and insert it using the generic type.
    /// It returns a Promise to inform if the request has finished succesfully or not
    ///
    /// - parameter endpoint: The endpoint
    ///
    /// - returns: The promise
    func enqueue<T: Insertable>(_ endpoint: Endpoint) -> Promise<T> {
        
        return Promise { fulfill, reject in
            let request = endpoint.request(withBaseURL: baseURL)
            
            prepare(request)
                .responseInsert(
                    queue: nil,
                    jsonSerializer: jsonSerialier,
                    context: context,
                    type: T.self) { response in
                        
                        switch response.result {
                        case let .success(value):
                            fulfill(value)
                        case let .failure(error):
                            reject(error)
                        }
            }
        }
    }
    
    /// Enqueues the request generated by the endpoint and insert it using the generic type.
    /// It returns an empty promise to inform if the request has finished succesfully or not
    ///
    /// - parameter endpoint: The endpoint
    ///
    /// - returns: The promise
    func enqueue(_ endpoint: Endpoint) -> Promise<Void> {
        
        return Promise { fulfill, reject in
            let request = endpoint.request(withBaseURL: baseURL)
            
            prepare(request)
                .responseInsert(
                    jsonSerializer: jsonSerialier,
                    context: context,
                    type: NSNull.self) { response in
                        
                        switch response.result {
                        case .success:
                            fulfill()
                        case let .failure(error):
                            reject(error)
                        }
            }
        }
    }
}

extension NSNull: Insertable {
    public static func insert(from json: Any, in context: NSManagedObjectContext) throws -> Self {
        return self.init()
    }
}
