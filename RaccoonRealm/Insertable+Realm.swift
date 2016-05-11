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

extension RealmSerializable where Self: Object {
    
    internal typealias ContextType = Realm
    
    internal static func create(inRealm realm: Realm, json: [String: AnyObject], update: Bool = true) -> Self {
        let convertedJSON = self.convertJSON(json)
        return realm.dynamicCreate(self.className(), value: convertedJSON, update: update) as! Self
    }
    
    public static func createOne(json: [String : AnyObject], context: Realm) throws -> AnyObject? {
        var value: AnyObject? = nil
        try context.write {
            value = create(inRealm: context, json: json)
        }
        
        return value
    }
    
    public static func createMany(array: [AnyObject], context: Realm) throws -> [AnyObject]? {
        var response: [AnyObject] = []
        
        try context.write({
            for object in array {
                let json = object as! [String: AnyObject]
                let value = create(inRealm: context, json: json)
                response.append(value)
            }
        })
        
        return response
    }
}
