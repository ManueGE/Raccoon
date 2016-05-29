//
//  Insertable+Realm.swift
//  raccoon
//
//  Created by Manu on 21/4/16.
//  Copyright © 2016 manuege. All rights reserved.
//

import RealmSwift
import Raccoon

// typealias RealmInsertable = protocol<RealmSerializable, Insertable>

extension Realm: InsertContext {}

extension Object: Insertable {
    
    public typealias ContextType = Realm
    
    private static func create(inRealm realm: Realm, json: [String: AnyObject], update: Bool = false) -> AnyObject {
        let convertedJSON = convertJSON(json)
        
        var update = update
        if self.primaryKey() == nil {
            update = false
        }
        
        return realm.dynamicCreate(self.className(), value: convertedJSON, update: update)
    }
    
    public static func createOne(json: [String : AnyObject], context: Realm) throws -> AnyObject? {
        var value: AnyObject? = nil
        try context.write {
            value = create(inRealm: context, json: json, update: true)
        }
        
        return value
    }
    
    public static func createMany(array: [AnyObject], context: Realm) throws -> [AnyObject]? {
        var response: [AnyObject] = []
        
        try context.write({
            for object in array {
                let json = object as! [String: AnyObject]
                let value = create(inRealm: context, json: json, update: true)
                response.append(value)
            }
        })
        
        return response
    }
}
