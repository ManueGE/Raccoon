//
//  RealmProjectTests.swift
//  RealmProjectTests
//
//  Created by Manu on 20/4/16.
//  Copyright © 2016 manuege. All rights reserved.
//

import XCTest
import RealmSwift
@testable import RaccoonRealm

class RealmProjectTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInsertSerializable() {
        let dictionary = [
            "id": 1,
            "Nombre": "Manue",
            "address": ["country": "Spain"],
            "birthday": "1983-11-18"
        ]
        
        let realm = try! Realm()
        
        try! realm.write() {
            let user = realm.create(User.self, json: dictionary, update: true)
            XCTAssertEqual(user.id, 1, "property does not match")
            XCTAssertEqual(user.name, "Manue", "property does not match")
            XCTAssertEqual(user.country, "Spain", "property does not match")
            XCTAssertNotNil(user.birthday, "property does not match")
            XCTAssertEqual(user.birthday, DateConverter.date(fromString: "1983-11-18"), "property does not match")
        }
    }
}
