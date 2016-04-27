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
    
    func testInsertSerializableWithModifiedKeyPaths() {
        
        // Given
        let dictionary = [
            "id": 1,
            "Nombre": "Manue",
            "address": ["country": "Spain"],
            "birthday": "1983-11-18"
        ]
        
        // When
        try! realm.write() {
            let user = realm.create(User.self, json: dictionary, update: true)
            
            // Then
            XCTAssertEqual(user.id, 1, "property does not match")
            XCTAssertEqual(user.name, "Manue", "property does not match")
            XCTAssertEqual(user.country, "Spain", "property does not match")
            XCTAssertNotNil(user.birthday, "property does not match")
            XCTAssertEqual(user.birthday, DateConverter.date(fromString: "1983-11-18"), "property does not match")
        }
    }
    
    func testInsertSerializableWithDefaultKeyPaths() {
        
        // Given
        let dictionary = [
            "id": 1,
            "name": "Manue"
        ]
        
        // When
        try! realm.write() {
            let user = realm.create(Role.self, json: dictionary, update: true)
            
            // Then
            XCTAssertEqual(user.id, 1, "property does not match")
            XCTAssertEqual(user.name, "Manue", "property does not match")
        }
    }
    
    func testSerializableWithMissingProperty() {
        // Given
        let dictionary = [
            "id": 1,
            "Nombre": "Manue",
            "address": ["country": "Spain"]
        ]
        
        // When
        try! realm.write() {
            let user = realm.create(User.self, json: dictionary, update: true)
            
            // Then
            XCTAssertNil(user.birthday, "property should be nil")
        }

    }
}
