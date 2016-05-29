//
//  FailClientTest.swift
//  raccoon
//
//  Created by Manu on 13/5/16.
//  Copyright © 2016 manuege. All rights reserved.
//

import XCTest
import RaccoonClient
import Raccoon
import Alamofire
import PromiseKit
import OHHTTPStubs

class FailClientTest: RaccoonClientTests {
    
    let endpoint = Endpoint(method: .GET, path: "path", parameters: ["param": "value"], encoding: .URLEncodedInURL, headers: ["header": "headerValue"])
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFailInsertable() {
        
        let responseArrived = self.expectationWithDescription("response of async request has arrived")
        var receivedObject: MyInsertable?
        var error: ErrorType?
        
        stubError()
        
        let promise = client.request(endpoint, type: MyInsertable.self)
        promise.then { (object) -> Void in
            receivedObject = object
            }
            .error { (_error) in
                responseArrived.fulfill()
                error = _error
        }
        
        self.waitForExpectationsWithTimeout(10) { err in
            XCTAssertNil(receivedObject, "Received data should be nil")
            
            XCTAssertNotNil(error, "Error shouldn't be nil")
            
            if let error = error as? NSError {
                XCTAssertEqual(error.domain, NSURLErrorDomain, "property does not match")
                XCTAssertEqual(error.code, 10, "property does not match")
            }
            
            else {
                XCTAssertTrue(false, "Error should be NSError")
            }
        }
    }
    
    func testFailInsertableArray() {
        
        let responseArrived = self.expectationWithDescription("response of async request has arrived")
        var receivedObject: [MyInsertable]?
        var error: ErrorType?
        
        stubError()
        
        let promise = client.request(endpoint, type: [MyInsertable].self)
        promise.then { (object) -> Void in
            receivedObject = object
            }
            .error { (_error) in
                responseArrived.fulfill()
                error = _error
        }
        
        self.waitForExpectationsWithTimeout(10) { err in
            XCTAssertNil(receivedObject, "Received data should be nil")
            
            XCTAssertNotNil(error, "Error shouldn't be nil")
            
            if let error = error as? NSError {
                XCTAssertEqual(error.domain, NSURLErrorDomain, "property does not match")
                XCTAssertEqual(error.code, 10, "property does not match")
            }
                
            else {
                XCTAssertTrue(false, "Error should be NSError")
            }
        }
    }
    
    func testFailWrapper() {
        
        let responseArrived = self.expectationWithDescription("response of async request has arrived")
        var receivedObject: MyWrapper?
        
        stubError()
        var error: ErrorType?
        
        let promise = client.request(endpoint, type: MyWrapper.self)
        promise.then { (object) -> Void in
            receivedObject = object
            }
            .error { (_error) in
                responseArrived.fulfill()
                error = _error
        }
        
        self.waitForExpectationsWithTimeout(10) { err in
            XCTAssertNil(receivedObject, "Received data should be nil")
            
            XCTAssertNotNil(error, "Error shouldn't be nil")
            
            if let error = error as? NSError {
                XCTAssertEqual(error.domain, NSURLErrorDomain, "property does not match")
                XCTAssertEqual(error.code, 10, "property does not match")
            }
                
            else {
                XCTAssertTrue(false, "Error should be NSError")
            }
        }
    }
    
    func testFailVoid() {
        
        let responseArrived = self.expectationWithDescription("response of async request has arrived")
        
        stubError()
        var error: ErrorType?
        
        let promise = client.request(endpoint) as Promise<Void>
        promise.error { (_error) in
                responseArrived.fulfill()
                error = _error
        }
        
        self.waitForExpectationsWithTimeout(3) { err in
            
            XCTAssertNotNil(error, "Error shouldn't be nil")
            
            if let error = error as? NSError {
                XCTAssertEqual(error.domain, NSURLErrorDomain, "property does not match")
                XCTAssertEqual(error.code, 10, "property does not match")
            }
                
            else {
                XCTAssertTrue(false, "Error should be NSError")
            }
        }
    }

    //MARK: Helper
    func stubError() {
        
        OHHTTPStubs.stubRequestsPassingTest({
            (request: NSURLRequest) -> Bool in
            return true
            }, withStubResponse: { (request: NSURLRequest) -> OHHTTPStubsResponse in
                let notConnectedError = NSError(domain:NSURLErrorDomain, code:10, userInfo:nil)
                return OHHTTPStubsResponse(error:notConnectedError)
        })
    }
    
    
}
