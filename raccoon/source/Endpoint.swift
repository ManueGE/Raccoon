//
//  Endpoint.swift
//  raccoon
//
//  Created by Manuel García-Estañ on 8/10/16.
//  Copyright © 2016 manuege. All rights reserved.
//

import Foundation
import Alamofire

/**
 Helper extension to build URLS from base URL string and path
 */
public extension URL {
    
    /**
     Creates a new URL with the given base and path.
     Internally it make use of `init(string: String, relativeTo: URL)` so same rules applies here.
     */
    init?(base: String, path: String) {
        guard let baseURL = URL(string: base) else {
            return nil
        }
        
        self.init(string: path, relativeTo: baseURL)
    }
}

/* An Endpoint is just an instance that can build a `DataRequest` from a base url.
 Use it to enqueue request in a client
 */
public protocol Endpoint {
    
    /**
     Returns a request built with the given base url
    
    - parameter baseURL: The base url to build the request
    
    - returns: The request ready to be sent.
     */
    func request(withBaseURL baseURL: String) -> DataRequest
}
