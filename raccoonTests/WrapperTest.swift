//
//  WrapperTest.swift
//  raccoon
//
//  Created by Manu on 13/4/16.
//  Copyright © 2016 manuege. All rights reserved.
//

import XCTest
@testable import raccoon

class WrapperTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testWrapperResponse() {
        
        let json = [
            "string": "this is a string",
            "date": "1983-11-18",
            "pagination": ["limit": 10, "offset": 20, "total": 100],
            
            "paginations": [
                ["limit": 20, "offset": NSNull()],
                ["limit": 15, "offset": 20, "total": 100]
            ]
        ]
        
        let object = Response(dictionary: json, context: NoContext())!
        
        XCTAssertNotNil(object, "object can not be nil")
        XCTAssertEqual(object.string, "this is a string", "property does not match")
        XCTAssertEqual(object.date, DateConverter.date(fromString: "1983-11-18"), "property does not match")
        
        XCTAssertEqual(object.pagination?.limit, 10, "property does not match")
        XCTAssertEqual(object.pagination?.offset, 20, "property does not match")
        XCTAssertEqual(object.pagination?.total, 100, "property does not match")
        
        XCTAssertEqual(object.paginations?.count, 2, "property does not match")
        XCTAssertNil(object.paginations!.first!.offset, "object can not be nil")
        XCTAssertEqual(object.paginations!.first!.total, 0, "property does not match")
        
    }
    
    /*
    func testGenericWrapperResponse() {
        
        let json = [
            "limit": 10,
            "offset": 20,
            "total": 100,
            
            "data": [
                ["id": 1, "name": "one"],
                ["id": 2, "name": "two"]
            ]
        ]
        
        let object = PaginatedResponse<Table>(dictionary: json, context: stack.mainQueueContext)!
        
        XCTAssertEqual(object.pagination.limit, 10, "property does not match")
        XCTAssertEqual(object.pagination.offset, 20, "property does not match")
        XCTAssertEqual(object.pagination.total, 100, "property does not match")
 
        XCTAssertEqual(object.data?.count, 2, "property does not match")
        XCTAssertEqual(object.data!.first!.identifier, 1, "object can not be nil")
        
    }
 */

}
