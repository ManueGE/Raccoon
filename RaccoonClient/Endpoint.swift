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

/// Closure that convert a given Endpoint to a Request
public typealias EndpointSerializer = Endpoint -> Request

/** 
 Class to represent a REST endpoint. It is similar to `Request`, but they don't have a full URL, just a path.
 */
public class Endpoint {
    public let method: Alamofire.Method
    public let path: String
    public let parameters: [String: AnyObject]?
    public let encoding: ParameterEncoding
    public let headers: [String: String]?
    
    public init(method: Alamofire.Method,
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

/**
 Protocol that must conform the objects that can be converted to `Endpoint`
 */
public protocol EndpointConvertible {
    var endpoint: Endpoint { get }
}

/**
 `Endpoint` adpot the `EndpointConvertible` protocol by returning themselves
 */
extension Endpoint: EndpointConvertible {
    public var endpoint: Endpoint {
        return self
    }
}