//
//  WrapperTest.swift
//  raccoon
//
//  Created by Manu on 13/4/16.
//  Copyright © 2016 manuege. All rights reserved.
//

import XCTest
@testable import Raccoon

class MyInsertable: NSObject, Insertable {
    var integer: Int
    var string: String
    
    typealias ContextType = NoContext
    
    init(integer: Int, string: String) {
        self.integer = integer
        self.string = string
    }
    
    static func createOne(json: [String : AnyObject], context: ContextType) throws -> AnyObject? {
        let integer = json["integer"] as! Int
        let string = json["string"] as! String
        return MyInsertable(integer: integer, string: string)
    }
    
    static func createMany(array: [AnyObject], context: ContextType) throws -> [AnyObject]? {
        return array.map({ (object) -> AnyObject in
            let json = object as! [String: AnyObject]
            return try! MyInsertable.createOne(json, context: context)!
        })
    }
    
}

class NestedWrapper: Wrapper {
    var integer: Int = 0
    var string: String = ""
    
    required init() {}
    
    func map(map: Map) {
        integer <- map["integer"]
        string <- map["string"]
    }

}

class MainWrapper: Wrapper {
    
    // Insertable
    var insertable = MyInsertable(integer: 0, string: "")
    var optInsertable: MyInsertable?
    var forceInsertable: MyInsertable!
    
    // Insertable arrays
    var insertableArray: [MyInsertable] = []
    var optInsertableArray: [MyInsertable]?
    var forceInsertableArray: [MyInsertable]!
    
    // Wrapper
    var wrapper = NestedWrapper()
    var optWrapper: NestedWrapper?
    var forceWrapper: NestedWrapper!
    
    // Wrapper array
    var wrapperArray: [NestedWrapper] = []
    var optWrapperArray: [NestedWrapper]?
    var forceWrapperArray: [NestedWrapper]!
    
    // Generic
    var string: String = ""
    
    var integer: Int = 0
    var optInteger: Int?
    var forceInteger: Int!
    
    // This won't be on the json, so its value shouldn't change
    var notOverridenInteger = 20
    var optNotOverridenInteger: Int? = 30
    
    required init() {}
    
    func map(map: Map) {
        // Insertable
        insertable <- map["insertable"]
        optInsertable <- map["optInsertable"]
        forceInsertable <- map["forceInsertable"]
        
        insertableArray <- map["insertableArray"]
        optInsertableArray <- map["optInsertableArray"]
        forceInsertableArray <- map["forceInsertableArray"]
        
        // Wrappers
        wrapper <- map["wrapper"]
        optWrapper <- map["optWrapper"]
        forceWrapper <- map["forceWrapper"]
        
        wrapperArray <- map["wrapperArray"]
        optWrapperArray <- map["optWrapperArray"]
        forceWrapperArray <- map["forceWrapperArray"]
        
        // Generics
        string <- map["string"]
        integer <- (map["integer"], { Int($0)! })
        optInteger <- (map["optInteger"], { Int($0)! })
        forceInteger <- (map["forceInteger"], { Int($0)! })
        
        // Not overriden
        notOverridenInteger <- (map["notOverridenInteger"], { Int($0)! })
        optNotOverridenInteger <- (map["optNotOverridenInteger"], { Int($0)! })
        
    }
}

class WrapperTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testWrapperFull() {
        
        let json = [
            "insertable": ["integer": 1, "string": "one"],
            "optInsertable": ["integer": 2, "string": "two"],
            "forceInsertable": ["integer": 3, "string": "three"],
            
            "insertableArray": [["integer": 1, "string": "one"]],
            "optInsertableArray": [["integer": 2, "string": "two"]],
            "forceInsertableArray": [["integer": 3, "string": "three"]],
            
            
            "wrapper": ["integer": 1, "string": "one"],
            "optWrapper": ["integer": 2, "string": "two"],
            "forceWrapper": ["integer": 3, "string": "three"],
            
            "wrapperArray": [["integer": 1, "string": "one"]],
            "optWrapperArray": [["integer": 2, "string": "two"]],
            "forceWrapperArray": [["integer": 3, "string": "three"]],
            
            "string": "I am a string",
            "integer": "10",
            "optInteger": NSNull(),
            "forceInteger": "20"
        ]
        
        let object = MainWrapper(dictionary: json, context: NoContext())!
        
        XCTAssertNotNil(object, "object can not be nil")
        
        // Insertables
        XCTAssertNotNil(object.insertable, "can not be nil")
        XCTAssertEqual(object.insertable.integer, 1, "property does not match")
        XCTAssertEqual(object.insertable.string, "one", "property does not match")
        
        XCTAssertNotNil(object.optInsertable, "can not be nil")
        XCTAssertEqual(object.optInsertable!.integer, 2, "property does not match")
        XCTAssertEqual(object.optInsertable!.string, "two", "property does not match")
        
        XCTAssertNotNil(object.forceInsertable, "can not be nil")
        XCTAssertEqual(object.forceInsertable.integer, 3, "property does not match")
        XCTAssertEqual(object.forceInsertable.string, "three", "property does not match")
        
        // Insertable Array
        XCTAssertNotNil(object.insertableArray, "can not be nil")
        XCTAssertEqual(object.insertableArray.count, 1, "count does not match")
        XCTAssertEqual(object.insertableArray.first!.integer, 1, "property does not match")
        XCTAssertEqual(object.insertableArray.first!.string, "one", "property does not match")
        
        XCTAssertNotNil(object.optInsertableArray, "can not be nil")
        XCTAssertEqual(object.optInsertableArray!.count, 1, "count does not match")
        XCTAssertEqual(object.optInsertableArray!.first!.integer, 2, "property does not match")
        XCTAssertEqual(object.optInsertableArray!.first!.string, "two", "property does not match")
        
        XCTAssertNotNil(object.forceInsertableArray, "can not be nil")
        XCTAssertEqual(object.forceInsertableArray.count, 1, "count does not match")
        XCTAssertEqual(object.forceInsertableArray.first!.integer, 3, "property does not match")
        XCTAssertEqual(object.forceInsertableArray.first!.string, "three", "property does not match")
        
        // Wrappers
        XCTAssertNotNil(object.wrapper, "can not be nil")
        XCTAssertEqual(object.wrapper.integer, 1, "property does not match")
        XCTAssertEqual(object.wrapper.string, "one", "property does not match")
        
        XCTAssertNotNil(object.optWrapper, "can not be nil")
        XCTAssertEqual(object.optWrapper!.integer, 2, "property does not match")
        XCTAssertEqual(object.optWrapper!.string, "two", "property does not match")
        
        XCTAssertNotNil(object.forceWrapper, "can not be nil")
        XCTAssertEqual(object.forceWrapper.integer, 3, "property does not match")
        XCTAssertEqual(object.forceWrapper.string, "three", "property does not match")
        
        // Wrapper Array
        XCTAssertNotNil(object.wrapperArray, "can not be nil")
        XCTAssertEqual(object.wrapperArray.count, 1, "count does not match")
        XCTAssertEqual(object.wrapperArray.first!.integer, 1, "property does not match")
        XCTAssertEqual(object.wrapperArray.first!.string, "one", "property does not match")
        
        XCTAssertNotNil(object.optWrapperArray, "can not be nil")
        XCTAssertEqual(object.optWrapperArray!.count, 1, "count does not match")
        XCTAssertEqual(object.optWrapperArray!.first!.integer, 2, "property does not match")
        XCTAssertEqual(object.optWrapperArray!.first!.string, "two", "property does not match")
        
        XCTAssertNotNil(object.forceWrapperArray, "can not be nil")
        XCTAssertEqual(object.forceWrapperArray.count, 1, "count does not match")
        XCTAssertEqual(object.forceWrapperArray.first!.integer, 3, "property does not match")
        XCTAssertEqual(object.forceWrapperArray.first!.string, "three", "property does not match")
        
        // Generics
        XCTAssertNotNil(object.string, "can not be nil")
        XCTAssertEqual(object.string, "I am a string", "property does not match")
        
        XCTAssertNotNil(object.integer, "can not be nil")
        XCTAssertEqual(object.integer, 10, "property does not match")
        
        XCTAssertNil(object.optInteger, "must be nil")
        
        XCTAssertNotNil(object.forceInteger, "can not be nil")
        XCTAssertEqual(object.forceInteger, 20, "property does not match")
        
        // Not overriden
        XCTAssertEqual(object.notOverridenInteger, 20, "property does not match")
        XCTAssertEqual(object.optNotOverridenInteger, 30, "property does not match")
    }
    
    /*
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
        XCTAssertNil(object.paginations?.first?.offset, "object can not be nil")
        XCTAssertEqual(object.paginations?.first?.total, 0, "property does not match")
        
    }
    */
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
