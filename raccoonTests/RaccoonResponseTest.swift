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

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    
    func testObjectSerializer() {
        // Given
        let serializer: ResponseSerializer<MyInsertable, NSError> = Request.raccoonResponseSerializer()
        
        let json = ["integer": 1, "string": "one"]
        let data = try! NSJSONSerialization.dataWithJSONObject(json, options: [])
        
        // When
        let result = serializer.serializeResponse(nil, nil, data, nil)
        
        // Then
        XCTAssertTrue(result.isSuccess, "result is success should be true")
        XCTAssertNotNil(result.value, "result value should not be nil")
        XCTAssertNil(result.error, "result error should be nil")
        
        XCTAssertEqual(result.value?.integer, 1, "property does not match")
        XCTAssertEqual(result.value?.string, "one", "property does not match")
    }
    
    
    func testArraySerializer() {
        // Given
        let serializer: ResponseSerializer<[MyInsertable], NSError> = Request.raccoonResponseSerializer()
        
        let json = [["integer": 1, "string": "one"], ["integer": 2, "string": "two"]]
        let data = try! NSJSONSerialization.dataWithJSONObject(json, options: [])
        
        // When
        let result = serializer.serializeResponse(nil, nil, data, nil)
        
        // Then
        XCTAssertTrue(result.isSuccess, "result is success should be true")
        XCTAssertNotNil(result.value, "result value should not be nil")
        XCTAssertNil(result.error, "result error should be nil")
        
        XCTAssertEqual(result.value?.count, 2, "property does not match")
        
        XCTAssertEqual(result.value?.first?.integer, 1, "property does not match")
        XCTAssertEqual(result.value?.first?.string, "one", "property does not match")
        
        XCTAssertEqual(result.value?.last?.integer, 2, "property does not match")
        XCTAssertEqual(result.value?.last?.string, "two", "property does not match")
    }
    

    func testEmptyArraySerializer() {
        // Given
        let serializer: ResponseSerializer<[MyInsertable], NSError> = Request.raccoonResponseSerializer()
        
        let json = []
        let data = try! NSJSONSerialization.dataWithJSONObject(json, options: [])
        
        // When
        let result = serializer.serializeResponse(nil, nil, data, nil)
        
        // Then
        XCTAssertTrue(result.isSuccess, "result is success should be true")
        XCTAssertNotNil(result.value, "result value should not be nil")
        XCTAssertNil(result.error, "result error should be nil")
        
        XCTAssertEqual(result.value?.count, 0, "property does not match")
    }
     
    
    func testWrapperSerializer() {
        
        class WrappedResponse: Wrapper {
            var string: String!
            var insertable: MyInsertable!
            var insertables: [MyInsertable]!
            
            required init() {}
            
            private func map(map: Map) {
                string <- map["string"]
                insertable <- map["table"]
                insertables <- map["tables"]
            }
        }
        
        // Given
        let serializer: ResponseSerializer<WrappedResponse, NSError> = Request.raccoonResponseSerializer()
        
        let json = [
            "string": "example",
            "tables": [["integer": 1, "string": "one"], ["integer": 2, "string": "two"]],
            "table": ["integer": 3, "string": "three"]
        ]
        
        let data = try! NSJSONSerialization.dataWithJSONObject(json, options: [])
        
        // When
        let result = serializer.serializeResponse(nil, nil, data, nil)
        
        // Then
        XCTAssertTrue(result.isSuccess, "result is success should be true")
        XCTAssertNotNil(result.value, "result value should not be nil")
        XCTAssertNil(result.error, "result error should be nil")
        
        XCTAssertEqual(result.value?.string, "example", "property does not match")
        XCTAssertEqual(result.value?.insertables.count, 2, "property does not match")
        XCTAssertEqual(result.value?.insertable.integer, 3, "property does not match")
    }
}
