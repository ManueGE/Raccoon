//
//  Endpoint.swift
//  raccoon
//
//  Created by Manu on 13/5/16.
//  Copyright © 2016 manuege. All rights reserved.
//

import Foundation
import Alamofire

//MARK: Endpoint
typealias EndpointSerializer = Endpoint -> Request

class Endpoint {
    var method: Alamofire.Method
    var path: String
    var parameters: [String: AnyObject]?
    var encoding: ParameterEncoding
    var headers: [String: String]?
    
    init(method: Alamofire.Method,
         path: String,
         parameters: [String: AnyObject] = [:],
         encoding: ParameterEncoding = .URL,
         headers: [String: String] = [:]) {
        
        self.method = method
        self.path = path
        self.parameters = parameters
        self.encoding = encoding
        self.headers = headers
    }
}

protocol EndpointConvertible {
    var endpoint: Endpoint { get }
}


extension Endpoint: EndpointConvertible {
    var endpoint: Endpoint {
        return self
    }
}