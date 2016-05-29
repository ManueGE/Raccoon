//
//  User+CoreDataProperties.swift
//  raccoon
//
//  Created by Manu on 26/4/16.
//  Copyright © 2016 manuege. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var id: NSNumber?
    @NSManaged var name: String?

}
