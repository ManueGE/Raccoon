//
//  User.swift
//  raccoon
//
//  Created by Manu on 26/4/16.
//  Copyright © 2016 manuege. All rights reserved.
//

import Foundation
import CoreData
import BNRCoreDataStack

class User: NSManagedObject {
}

// Just for make tests easier
extension User: CoreDataModelable {
    static var entityName: String { return "User" }
}

// A class wich won't be on the context to be used in fail tests
class FakeUser: NSManagedObject {}
