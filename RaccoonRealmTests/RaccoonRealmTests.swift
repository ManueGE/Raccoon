//
//  RaccoonRealmTests.swift
//  raccoon
//
//  Created by Manu on 27/4/16.
//  Copyright © 2016 manuege. All rights reserved.
//

import XCTest
@testable import RaccoonRealm
import Raccoon
import RealmSwift

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
        let user = try! User.createOne(json, context: realm) as! User
        
        // Then
        XCTAssertEqual(user.id, 1, "property does not match")
        XCTAssertEqual(user.name, "manueGE", "property does not match")
        
    }
    
    func testCreateMany() {
        // Given
        let json = [
            ["id": 1, "Nombre": "manueGE"],
            ["id": 2, "Nombre": "batman"]
        ]
        
        // When
        let users = try! User.createMany(json, context: realm) as! [User]
        
        // Then
        XCTAssertEqual(users.count, 2, "count does not match")
    }
    
    // MARK: Fail test
    /*
    func testFailCreateOne() {
        // Given
        let json = ["id": 1, "name": "manueGE"]
        
        // When / Then
        do {
            let _ = try FakeUser.createOne(json, context: realm) as? FakeUser
            XCTFail("shouldn't arrive here")
        }
        catch let e as MGECoreDataKitContextError {
            XCTAssertEqual(e, MGECoreDataKitContextError.EntityNotFound)
        }
        catch {
            XCTFail("wrong error")
        }
        
    }

    
    // MARK: Fail test
    func testFailCreateMany() {
        // Given
        let json = [
            ["id": 1, "name": "manueGE"],
            ["id": 2, "name": "batman"]
        ]
        
        // When / Then
        do {
            let _ = try FakeUser.createMany(json, context: stack.mainQueueContext) as? [FakeUser]
            XCTFail("shouldn't arrive here")
        }
        catch let e as MGECoreDataKitContextError {
            XCTAssertEqual(e, MGECoreDataKitContextError.EntityNotFound)
        }
        catch {
            XCTFail("wrong error")
        }
        
    }
  */
    
}
