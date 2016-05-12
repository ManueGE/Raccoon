//
//  RaccoonCoreDataTests.swift
//  RaccoonCoreDataTests
//
//  Created by Manu on 26/4/16.
//  Copyright © 2016 manuege. All rights reserved.
//

import XCTest
@testable import RaccoonCoreData
import Raccoon
import BNRCoreDataStack

class RaccoonCoreDataTests: XCTestCase {
    
    var stack: CoreDataStack!
    
    override func setUp() {
        super.setUp()
        stack = try! CoreDataStack.constructInMemoryStack(withModelName: "Model", inBundle: NSBundle(forClass: self.dynamicType))
    }
    
    override func tearDown() {
        try! User.removeAllInContext(stack.mainQueueContext)
        super.tearDown() 
    }
    
    // MARK: Success test
    func testCreateOne() {
        // Given
        let json = ["id": 1, "name": "manueGE"]
        
        // When
        let user = try! User.createOne(json, context: stack.mainQueueContext) as! User
        
        // Then
        XCTAssertEqual(user.id, 1, "property does not match")
        XCTAssertEqual(user.name, "manueGE", "property does not match")
        
    }
    
    func testCreateMany() {
        // Given
        let json = [
            ["id": 1, "name": "manueGE"],
            ["id": 2, "name": "batman"]
        ]
        
        // When
        let users = try! User.createMany(json, context: stack.mainQueueContext) as! [User]
        
        // Then
        XCTAssertEqual(users.count, 2, "count does not match")
    }
    
    // MARK: Fail test
    func testFailCreateOne() {
        // Given
        let json = ["id": 1, "name": "manueGE"]

        // When / Then
        do {
            let _ = try FakeUser.createOne(json, context: stack.mainQueueContext) as? FakeUser
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
}
