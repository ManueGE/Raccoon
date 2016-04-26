//
//  NSManagedObjectContext+RaccoonCoreData.swift
//  raccoon
//
//  Created by Manu on 26/4/16.
//  Copyright © 2016 manuege. All rights reserved.
//

import Foundation
import CoreData

internal enum MGECoreDataKitContextError : ErrorType {
    case EntityNotFound
}

internal extension NSManagedObjectContext {
    
    /**
     - Returns: the entity description for given class has in the receiver context
     - Throws: if the class is not an entity of the context
     */
    func entityDescriptionForClass(aClass: NSManagedObject.Type) throws -> NSEntityDescription {
        
        let entityName = NSStringFromClass(aClass)
        let model = persistentStoreCoordinator!.managedObjectModel
        
        for entityDescription in model.entities {
            
            if entityDescription.managedObjectClassName == entityName {
                return entityDescription
            }
            
        }
        
        throw(MGECoreDataKitContextError.EntityNotFound)
    }
}