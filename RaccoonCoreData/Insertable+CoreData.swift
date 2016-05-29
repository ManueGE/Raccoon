//
//  Insertable+CoreData.swift
//  raccoon
//
//  Created by Manu on 21/4/16.
//  Copyright © 2016 manuege. All rights reserved.
//

import CoreData
import Raccoon
import Groot

extension NSManagedObjectContext: InsertContext {
}


/**
 Insert managed object cotexts using Groot.
 */
extension NSManagedObject: Insertable {
    
    public typealias ContextType = NSManagedObjectContext
    
    public static func createOne(json: [String : AnyObject], context: NSManagedObjectContext) throws -> AnyObject? {
        
        let entityDescription = try context.entityDescriptionForClass(self)
        let entityName = entityDescription.name
        
        return try objectWithEntityName(entityName!,
                                        fromJSONDictionary: json,
                                        inContext: context)
        
        
    }
    
    public static func createMany(array: [AnyObject], context: NSManagedObjectContext) throws -> [AnyObject]? {
        
        let entityDescription = try context.entityDescriptionForClass(self)
        let entityName = entityDescription.name

        return try objectsWithEntityName(entityName!,
                                          fromJSONArray: array,
                                          inContext: context)
    }
}