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

    /*
    func testObjectSerializer() {
        // Given
        let serializer: ResponseSerializer<Table, NSError> = Request.raccoonResponseSerializer(stack.mainQueueContext)
        
        let json = ["id": 1, "name": "one"]
        let data = try! NSJSONSerialization.dataWithJSONObject(json, options: [])
        
        // When
        let result = serializer.serializeResponse(nil, nil, data, nil)
        
        // Then
        XCTAssertTrue(result.isSuccess, "result is success should be true")
        XCTAssertNotNil(result.value, "result value should not be nil")
        XCTAssertNil(result.error, "result error should be nil")
        
        XCTAssertEqual(result.value?.identifier, 1, "property does not match")
        XCTAssertEqual(result.value?.name, "one", "property does not match")
    }
    
    func testArraySerializer() {
        // Given
        let serializer: ResponseSerializer<[Table], NSError> = Request.raccoonResponseSerializer(stack.mainQueueContext)
        
        let json = [["id": 1, "name": "one"], ["id": 2, "name": "two"]]
        let data = try! NSJSONSerialization.dataWithJSONObject(json, options: [])
        
        // When
        let result = serializer.serializeResponse(nil, nil, data, nil)
        
        // Then
        XCTAssertTrue(result.isSuccess, "result is success should be true")
        XCTAssertNotNil(result.value, "result value should not be nil")
        XCTAssertNil(result.error, "result error should be nil")
        
        XCTAssertEqual(result.value?.count, 2, "property does not match")
    }
    
    func testEmptyArraySerializer() {
        // Given
        let serializer: ResponseSerializer<[Table], NSError> = Request.raccoonResponseSerializer(stack.mainQueueContext)
        
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
            var table: Table!
            var tables: [Table]!
            
            required init() {}
            
            private func map(map: Map) {
                string <- map["string"]
                table <- map["table"]
                tables <- map["tables"]
            }
        }
        
        // Given
        let serializer: ResponseSerializer<WrappedResponse, NSError> = Request.raccoonResponseSerializer(stack.mainQueueContext)
        
        let json = [
            "string": "example",
            "tables": [["id": 1, "name": "one"], ["id": 2, "name": "two"]],
            "table": ["id": 3, "name": "three"]
        ]
        
        let data = try! NSJSONSerialization.dataWithJSONObject(json, options: [])
        
        // When
        let result = serializer.serializeResponse(nil, nil, data, nil)
        
        // Then
        XCTAssertTrue(result.isSuccess, "result is success should be true")
        XCTAssertNotNil(result.value, "result value should not be nil")
        XCTAssertNil(result.error, "result error should be nil")
        
        XCTAssertEqual(result.value?.string, "example", "property does not match")
        XCTAssertEqual(result.value?.tables.count, 2, "property does not match")
        XCTAssertEqual(result.value?.table.identifier, 3, "property does not match")
    }
 */

}
