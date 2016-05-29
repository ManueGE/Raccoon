//
//  RaccoonRealmTests.swift
//  raccoon
//
//  Created by Manu on 27/4/16.
//  Copyright © 2016 manuege. All rights reserved.
//

import XCTest
import Raccoon
import RealmSwift
import Alamofire

class RaccoonRealmTests: XCTestCase {
    
    let realm = try! Realm()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        try! realm.write {
            realm.deleteAll()
        }
        
        super.tearDown()
    }
    
    // MARK: Success test
    func testCreateOne() {
        // Given
        let json = ["id": 1, "Nombre": "manueGE"]
        
        // When
        let employer = try! Employer.createOne(json, context: realm) as! Employer
        
        // Then
        XCTAssertEqual(employer.id, 1, "property does not match")
        XCTAssertEqual(employer.name, "manueGE", "property does not match")
        
    }
    
    func testCreateMany() {
        // Given
        let json = [
            ["id": 1, "Nombre": "manueGE"],
            ["id": 2, "Nombre": "batman"]
        ]
        
        // When
        let employers = try! Employer.createMany(json, context: realm) as! [Employer]
        
        // Then
        XCTAssertEqual(employers.count, 2, "count does not match")
    }
    
    func testObjectSerializer() {
        
        var result: Alamofire.Result<Employer, NSError>!
        let responseArrived = self.expectationWithDescription("response of async request has arrived")
        let json = ["id": 1, "Nombre": "one"]
        
        stubWithObject(json)
        
        let request = Alamofire.request(NSURLRequest())
        request.response(Employer.self, context: realm) { (response) in
            result = response.result
            responseArrived.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10) { err in
            XCTAssertTrue(result.isSuccess, "result is success should be true")
            XCTAssertNotNil(result.value, "result value should not be nil")
            XCTAssertNil(result.error, "result error should be nil")
            
            XCTAssertEqual(result.value?.id, 1, "property does not match")
            XCTAssertEqual(result.value?.name, "one", "property does not match")
        }
    }

    func testObjectWithNotPrimryKeySerializer() {
        
        var result: Alamofire.Result<Department, NSError>!
        let responseArrived = self.expectationWithDescription("response of async request has arrived")
        let json = [:]
        
        stubWithObject(json)
        
        let request = Alamofire.request(NSURLRequest())
        request.response(Department.self, context: realm) { (response) in
            result = response.result
            responseArrived.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10) { err in
            XCTAssertTrue(result.isSuccess, "result is success should be true")
            XCTAssertNotNil(result.value, "result value should not be nil")
            XCTAssertNil(result.error, "result error should be nil")
            
            XCTAssertEqual(result.value?.id, 1, "property does not match")
            XCTAssertEqual(result.value?.name, "Bosses", "property does not match")
        }
    }
}
