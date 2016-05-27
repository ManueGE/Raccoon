//
//  Insertable+Realm.swift
//  raccoon
//
//  Created by Manu on 21/4/16.
//  Copyright © 2016 manuege. All rights reserved.
//

import Foundation
import RealmSwift

// MARK: KeyPath
@objc public protocol KeyPathConvertible {
    func value(inJSON json: [String: AnyObject]) -> AnyObject?;
}

extension NSString: KeyPathConvertible {
    public func value(inJSON json: [String : AnyObject]) -> AnyObject? {
        return (json as NSDictionary).valueForKeyPath(self as String)
    }
}

public class KeyPathTransformer<JSONType, PropertyType>: NSObject, KeyPathConvertible {
    public let keyPath: String
    public let transformer: (JSONType -> PropertyType?)
    
    public init(keyPath: String, transformer: (JSONType -> PropertyType?)) {
        self.keyPath = keyPath
        self.transformer = transformer
    }
    
    public func value(inJSON json: [String : AnyObject]) -> AnyObject? {
        guard let rawValue = keyPath.value(inJSON: json) else {
            return nil
        }
        
        if rawValue is NSNull {
            return NSNull()
        }
        
        return transformer(rawValue as! JSONType) as? AnyObject
    }
}

// MARK: Realm
public extension Realm {
    public func create<T: Object>(_: T.Type, json: [String: AnyObject], update: Bool = false) -> T {
        let convertedJSON = T.convertJSON(json)
        var update = update
        if T.primaryKey() == nil {
            update = false
        }
        return create(T.self, value: convertedJSON, update: update)
    }
}

// MARK: Realm object
public extension Object {
    class var keyPathsByProperties: [String: KeyPathConvertible]? {
        return nil
    }
    
    class func convertJSON(json: [String: AnyObject]) -> [String: AnyObject] {
        
        guard let keyPathsByProperties = keyPathsByProperties else {
            return json
        }
        
        var response: [String: AnyObject] = [:]
        
        for (propertyName, keyPath) in keyPathsByProperties {
            
            guard let value = keyPath.value(inJSON: json) else {
                continue
            }
            
            response[propertyName] = value
        }
        
        return response
    }
}
