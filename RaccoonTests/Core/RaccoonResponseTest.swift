//
//  RaccoonResponseTest.swift
//  raccoon
//
//  Created by Manu on 13/4/16.
//  Copyright © 2016 manuege. All rights reserved.
//

import XCTest
@testable import Raccoon
import Alamofire

// http://stackoverflow.com/questions/26918593/unit-testing-http-traffic-in-alamofire-app
class RaccoonResponseTest: XCTestCase {
    
    // MARK: Insertable
    
    func testObjectSerializer() {
        
        var result: Result<MyInsertable, NSError>!
        let responseArrived = self.expectationWithDescription("response of async request has arrived")
        let json = ["integer": 1, "string": "one"]
        stubWithObject(json)
    
        let request = Alamofire.request(NSURLRequest())
        request.response(MyInsertable.self) { (response) in
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
    

    func testArraySerializer() {
        
        var result: Result<[MyInsertable], NSError>!
        let responseArrived = self.expectationWithDescription("response of async request has arrived")
        let json = [["integer": 1, "string": "one"], ["integer": 2, "string": "two"]]
        stubWithObject(json)
        
        let request = Alamofire.request(NSURLRequest())
        request.response([MyInsertable].self, context: NoContext(), converter: nil) { (response) in
            result = response.result
            responseArrived.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10) { err in
            XCTAssertTrue(result.isSuccess, "result is success should be true")
            XCTAssertNotNil(result.value, "result value should not be nil")
            XCTAssertNil(result.error, "result error should be nil")
            
            XCTAssertEqual(result.value?.count, 2, "property does not match")
            
            XCTAssertEqual(result.value?.first?.integer, 1, "property does not match")
            XCTAssertEqual(result.value?.first?.string, "one", "property does not match")
            
            XCTAssertEqual(result.value?.last?.integer, 2, "property does not match")
            XCTAssertEqual(result.value?.last?.string, "two", "property does not match")
        } 
    }
    

    func testEmptyArraySerializer() {
        
        var result: Result<[MyInsertable], NSError>!
        let responseArrived = self.expectationWithDescription("response of async request has arrived")
        let json = []
        stubWithObject(json)
        
        let request = Alamofire.request(NSURLRequest())
        request.response([MyInsertable].self, context: NoContext(), converter: nil) { (response) in
            result = response.result
            responseArrived.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10) { err in
            XCTAssertTrue(result.isSuccess, "result is success should be true")
            XCTAssertNotNil(result.value, "result value should not be nil")
            XCTAssertNil(result.error, "result error should be nil")
            
            XCTAssertEqual(result.value?.count, 0, "property does not match")
        }
    }
     
    
    // MARK: Wrapper 
    class WrappedResponse: Wrapper {
        var string: String!
        var insertable: MyInsertable!
        var insertables: [MyInsertable]!
        
        required init() {}
        
        func map(map: Map) {
            string <- map["string"]
            insertable <- map["table"]
            insertables <- map["tables"]
        }
    }
    
    func testWrapperSerializer() {
        
        var result: Result<WrappedResponse, NSError>!
        let responseArrived = self.expectationWithDescription("response of async request has arrived")
        let json = [
            "string": "example",
            "tables": [["integer": 1, "string": "one"], ["integer": 2, "string": "two"]],
            "table": ["integer": 3, "string": "three"]
        ]
        
        stubWithObject(json)
        
        let request = Alamofire.request(NSURLRequest())
        
        request.response(WrappedResponse.self, context: NoContext(), converter: nil) { (response) in
            result = response.result
            responseArrived.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10) { err in
            XCTAssertTrue(result.isSuccess, "result is success should be true")
            XCTAssertNotNil(result.value, "result value should not be nil")
            XCTAssertNil(result.error, "result error should be nil")
            
            XCTAssertEqual(result.value?.string, "example", "property does not match")
            XCTAssertEqual(result.value?.insertables.count, 2, "property does not match")
            XCTAssertEqual(result.value?.insertable.integer, 3, "property does not match")
        }
    }
    
    func testWrapperArraySerializer() {
        var result: Result<[WrappedResponse], NSError>!
        let responseArrived = self.expectationWithDescription("response of async request has arrived")
        let json: [[String: AnyObject]] = [
            [
                "string": "example"
            ],
            
            [
                "string": "example2"
            ]
        ]
        
        stubWithObject(json)
        
        let request = Alamofire.request(NSURLRequest())
        
        request.response([WrappedResponse].self, context: NoContext(), converter: nil) { (response) in
            result = response.result
            responseArrived.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10) { err in
            XCTAssertTrue(result.isSuccess, "result is success should be true")
            XCTAssertNotNil(result.value, "result value should not be nil")
            XCTAssertNil(result.error, "result error should be nil")
            
            XCTAssertEqual(result.value?.count, 2, "property does not match")
            XCTAssertEqual(result.value?.first!.string, "example", "property does not match")
            XCTAssertEqual(result.value?.last!.string, "example2", "property does not match")
        }

    }
    
    func testEmptySerializer() {
        
        var result: EmptyResponse!
        let responseArrived = self.expectationWithDescription("response of async request has arrived")
        let json = []
        
        stubWithObject(json)
        
        let request = Alamofire.request(NSURLRequest())
        request.emptyResponse { (response) in
            result = response
            responseArrived.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10) { err in
            XCTAssertTrue(result.isSuccess, "result should success")
            XCTAssertFalse(result.isFailure, "result should not fail")
        }
    }
    
    func testEmptySerializerFail() {
        
        var result: EmptyResponse!
        let responseArrived = self.expectationWithDescription("response of async request has arrived")
        
        stubError()
        
        let request = Alamofire.request(NSURLRequest())
        request.emptyResponse { (response) in
            result = response
            responseArrived.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10) { err in
            XCTAssertTrue(result.isFailure, "result should fail")
            XCTAssertFalse(result.isSuccess, "result should not succeed")
        }
    }
}
