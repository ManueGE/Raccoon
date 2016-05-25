//
//  EndpointClientTests.swift
//  raccoon
//
//  Created by Manu on 13/5/16.
//  Copyright © 2016 manuege. All rights reserved.
//

import XCTest
@testable import RaccoonClient
import Raccoon
import Alamofire
import PromiseKit

struct MyRequestConvertible: URLRequestConvertible {
    let URLRequest: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: apiUrl)!)
}

class RequestConvertibleClientTests: RaccoonClientTests {
    
    let theRequest = MyRequestConvertible()
    
    func testRequestConvertibleInsertable() {
        
        let responseArrived = self.expectationWithDescription("response of async request has arrived")
        var receivedObject: MyInsertable?
        
        stubWithObject(["integer": 10, "string": "ten"])
        
        let promise = client.enqueue(theRequest) as Promise<MyInsertable>
        promise.then { (object) -> Void in
            receivedObject = object
            }
            .always {
                responseArrived.fulfill()
            }
            .error { (error) in
                print(error)
        }
        
        self.waitForExpectationsWithTimeout(10) { err in
            XCTAssertNotNil(receivedObject, "Received data should not be nil")
            XCTAssertEqual(receivedObject?.integer, 10, "property does not match")
            XCTAssertEqual(receivedObject?.string, "ten", "property does not match")
        }
    }
    
    
    func testRequestConvertibleInsertableArray() {
        
        let responseArrived = self.expectationWithDescription("response of async request has arrived")
        var receivedObject: [MyInsertable]?
        
        stubWithObject([["integer": 10, "string": "ten"], ["integer": 20, "string": "twenty"]])
        
        let promise = client.enqueue(theRequest) as Promise<[MyInsertable]>
        promise.then { (object) -> Void in
            receivedObject = object
            }
            .always {
                responseArrived.fulfill()
            }
            .error { (error) in
                print(error)
        }
        
        self.waitForExpectationsWithTimeout(10) { err in
            XCTAssertNotNil(receivedObject, "Received data should not be nil")
            XCTAssertEqual(receivedObject?.count, 2, "Received data should not be nil")
            XCTAssertEqual(receivedObject?.first?.integer, 10, "property does not match")
            XCTAssertEqual(receivedObject?.first?.string, "ten", "property does not match")
            XCTAssertEqual(receivedObject?.last?.integer, 20, "property does not match")
            XCTAssertEqual(receivedObject?.last?.string, "twenty", "property does not match")
        }
    }
    
    
    func testRequestConvertibleWrapper() {
        
        let responseArrived = self.expectationWithDescription("response of async request has arrived")
        var receivedObject: MyWrapper?
        
        stubWithObject(["string": "my string", "insertable": ["integer": 10, "string": "ten"]])
        
        let promise = client.enqueue(theRequest) as Promise<MyWrapper>
        promise.then { (object) -> Void in
            receivedObject = object
            }
            .always {
                responseArrived.fulfill()
            }
            .error { (error) in
                print(error)
        }
        
        self.waitForExpectationsWithTimeout(10) { err in
            XCTAssertNotNil(receivedObject, "Received data should not be nil")
            
            XCTAssertEqual(receivedObject?.string, "my string", "property does not match")
            
            XCTAssertNotNil(receivedObject?.insertable, "Received data should not be nil")
            XCTAssertEqual(receivedObject?.insertable?.integer, 10, "property does not match")
            XCTAssertEqual(receivedObject?.insertable?.string, "ten", "property does not match")
        }
    }
    
    func testRequestConvertibleVoid() {
        
        let responseArrived = self.expectationWithDescription("response of async request has arrived")
        var success = false
        
        stubWithObject(["string": "my string", "insertable": ["integer": 10, "string": "ten"]])
        
        let promise = client.enqueue(theRequest) as Promise<Void>
        promise.then { () -> Void in
            success = true
            }
            .always {
                responseArrived.fulfill()
            }
            .error { (error) in
                print(error)
        }
        
        self.waitForExpectationsWithTimeout(10) { err in
            XCTAssert(success, "The request must succeed")
        }
    }
}