//
//  RealmProjectTests.swift
//  RealmProjectTests
//
//  Created by Manu on 20/4/16.
//  Copyright © 2016 manuege. All rights reserved.
//

import XCTest
import RealmSwift
import Raccoon

class RealmProjectTests: XCTestCase {
    
    let realm = try! Realm()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        try! realm.write {
            realm.deleteAll()
            super.tearDown()
        }
    }
    
    func testInsertSerializableWithModifiedKeyPaths() {
        
        // Given
        let dictionary = [
            "id": 1,
            "Nombre": "Manue",
            "address": ["country": "Spain"],
            "birthday": "1983-11-18",
        ]
        
        // When
        try! realm.write() {
            let employer = realm.create(Employer.self, json: dictionary, update: true)
            
            // Then
            XCTAssertEqual(employer.id, 1, "property does not match")
            XCTAssertEqual(employer.name, "Manue", "property does not match")
            XCTAssertEqual(employer.country, "Spain", "property does not match")
            XCTAssertNotNil(employer.birthday, "property does not match")
            XCTAssertEqual(employer.birthday, DateConverter.date(fromString: "1983-11-18"), "property does not match")
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
            let role = realm.create(Role.self, json: dictionary, update: true)
            
            // Then
            XCTAssertEqual(role.id, 1, "property does not match")
            XCTAssertEqual(role.name, "Manue", "property does not match")
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
            let employer = realm.create(Employer.self, json: dictionary, update: true)
            
            // Then
            XCTAssertNil(employer.birthday, "property should be nil")
        }
    }
    
    func testSerializableWithNullProperty() {
        // Given
        let dictionary = [
            "id": 1,
            "created": NSNull()
        ]
        
        // When
        try! realm.write() {
            let previousEmployer = realm.create(Employer.self, value: ["id": 1])
            previousEmployer.name = "manu"
            previousEmployer.created = NSDate()
            
            let employer = realm.create(Employer.self, json: dictionary, update: true)
            
            // Then
            XCTAssertEqual(employer, previousEmployer, "property does not match")
            XCTAssertEqual(employer.name, "manu", "property does not match")
            XCTAssertNil(employer.created, "property should be nil")
        }
    }
    
    func testSerializableWithNotPrimrykey() {
        let json = [:] as [String: AnyObject]
        
        try! realm.write() {
            let department = realm.create(Department.self, json: json, update: true)
            XCTAssertNotNil(department, "shouldn't be nil")
            XCTAssertEqual(department.id, 1, "property does not match")
            XCTAssertEqual(department.name, "Bosses", "property does not match")
        }
        
    }
}
