//
//  Helpers.swift
//  raccoon
//
//  Created by Manu on 28/5/16.
//  Copyright © 2016 manuege. All rights reserved.
//

import Foundation
import OHHTTPStubs

func stubWithObject(object: AnyObject) {
    
    OHHTTPStubs.stubRequestsPassingTest({
        (request: NSURLRequest) -> Bool in
        return true
        }, withStubResponse: { (request: NSURLRequest) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(JSONObject: object, statusCode:200, headers:nil)
    })
}

func stubError() {
    
    OHHTTPStubs.stubRequestsPassingTest({
        (request: NSURLRequest) -> Bool in
        return true
        }, withStubResponse: { (request: NSURLRequest) -> OHHTTPStubsResponse in
            let notConnectedError = NSError(domain:NSURLErrorDomain, code:10, userInfo:nil)
            return OHHTTPStubsResponse(error:notConnectedError)
    })
}