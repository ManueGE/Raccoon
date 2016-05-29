//
//  RaccoonResponseConverterTest.swift
//  raccoon
//
//  Created by Manu on 25/5/16.
//  Copyright © 2016 manuege. All rights reserved.
//

import XCTest
@testable import RaccoonCore
import Alamofire

func SuccessResponseSerializer(data: NSData?) throws -> NSData? {
   
    guard let _ = data else {
        return nil
    }
    
    let dictionary = ["integer": 1, "string": "one"]
    
    return try? NSJSONSerialization.dataWithJSONObject(dictionary, options: [])
    
}

func ErrorResponseSerializer(data: NSData?) throws -> NSData? {
    throw NSError(domain: "ErrorDomain", code: 10, userInfo: nil)
}

class RaccoonResponseConverterTest: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testResponseSerializer() {
        
        var result: Result<MyInsertable, NSError>!
        let responseArrived = self.expectationWithDescription("response of async request has arrived")
        let json = ["": ""] // empty json, it will be converted
        
        stubWithObject(json)
        
        let request = Alamofire.request(NSURLRequest())
        request.response(MyInsertable.self, converter: SuccessResponseSerializer) { (response) in
            result = response.result
            responseArrived.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10) { err in
            XCTAssertTrue(result.isSuccess, "result is success should be true")
            XCTAssertNotNil(result.value, "result value should not be nil")
            XCTAssertNil(result.error, "result error should be nil")
            
            XCTAssertEqual(result.value?.integer, 1, "property does not match")
            XCTAssertEqual(result.value?.string, "one", "property does not match")
        }
    }
    
    func testFailResponseSerializer() {
        
        var result: Result<MyInsertable, NSError>!
        let responseArrived = self.expectationWithDescription("response of async request has arrived")
        let json = ["": ""] // empty json, it will be converted
        
        stubWithObject(json)
        
        let request = Alamofire.request(NSURLRequest())
        request.response(MyInsertable.self, converter: ErrorResponseSerializer) { (response) in
            result = response.result
            responseArrived.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10) { err in
            XCTAssertTrue(!result.isSuccess, "result is success should be false")
            XCTAssertNil(result.value, "result value should not be nil")
            XCTAssertNotNil(result.error, "result error should be nil")
            
            XCTAssertEqual(result.error?.domain, "ErrorDomain", "property does not match")
            XCTAssertEqual(result.error?.code, 10, "property does not match")
        }
        
    }
}
