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
@objc public protocol KeyPathConvertible: AnyObject {
    func value(inJSON json: [String: AnyObject]) -> AnyObject?;
}

extension NSString: KeyPathConvertible {
    public func value(inJSON json: [String : AnyObject]) -> AnyObject? {
        return (json as NSDictionary).valueForKeyPath(self as String)
    }
}

class KeyPathTransformer<JSONType, PropertyType>: KeyPathConvertible {
    let keyPath: String
    let transformer: (JSONType -> PropertyType?)
    
    init(keyPath: String, transformer: (JSONType -> PropertyType?)) {
        self.keyPath = keyPath
        self.transformer = transformer
    }
    
    @objc func value(inJSON json: [String : AnyObject]) -> AnyObject? {
        guard let rawValue = keyPath.value(inJSON: json) else {
            return nil
        }
        return transformer(rawValue as! JSONType) as? AnyObject
    }
}

// MARK: Realm
extension Realm {
    func create<T: Object>(_: T.Type, json: [String: AnyObject], update: Bool = false) -> T {
        let convertedJSON = T.convertJSON(json)
        return create(T.self, value: convertedJSON, update: update)
    }
}

// MARK: Realm serializable
public extension Object {
    @objc class var keyPathsByProperties: [String: KeyPathConvertible]? {
        return nil
    }
    
    static func convertJSON(json: [String: AnyObject]) -> [String: AnyObject] {
        
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
