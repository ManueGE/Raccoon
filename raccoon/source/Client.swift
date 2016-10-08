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

open class Client {
    public let baseURL: String
    public let context: NSManagedObjectContext
    public let jsonSerialier: DataResponseSerializer<Any> = DataRequest.jsonResponseSerializer()
    
    public var queue: DispatchQueue?
    
    init(baseURL: String, context: NSManagedObjectContext) {
        self.baseURL = baseURL
        self.context = context
    }
    
    func process(_ request: DataRequest) -> DataRequest {
        return request
    }
    
    func enqueue<T: Insertable>(_ endpoint: Endpoint) -> Promise<T> {
        
        return Promise { fulfill, reject in
            let request = endpoint.request(withBaseURL: baseURL)
            
            process(request)
                .responseInsert(
                    queue: queue,
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
    
    // TODO: Add void
}
