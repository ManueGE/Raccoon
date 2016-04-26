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
public protocol KeyPathConvertible {
    func value(inJSON json: [String: AnyObject]) -> AnyObject?;
}

extension String: KeyPathConvertible {
    public func value(inJSON json: [String : AnyObject]) -> AnyObject? {
        return (json as NSDictionary).valueForKeyPath(self)
    }
}

struct KeyPathTransformer<JSONType, PropertyType>: KeyPathConvertible {
    let keyPath: String
    let transformer: (JSONType -> PropertyType?)
    
    init(keyPath: String, transformer: (JSONType -> PropertyType?)) {
        self.keyPath = keyPath
        self.transformer = transformer
    }
    
    func value(inJSON json: [String : AnyObject]) -> AnyObject? {
        guard let rawValue = keyPath.value(inJSON: json) as? JSONType else {
            return nil
        }
        
        return transformer(rawValue) as? AnyObject
    }
}

// MARK: Realm
extension Realm {
    func create<T: Object where T: RealmSerializable>(_: T.Type, json: [String: AnyObject], update: Bool = false) -> T {
        let convertedJSON = T.convertJSON(json)
        return create(T.self, value: convertedJSON, update: update)
    }
}

// MARK: Realm serializable
public protocol RealmSerializable: NSObjectProtocol {
    static var keyPathsByProperties: [String: KeyPathConvertible]? { get }
}

extension RealmSerializable {
    public static var keyPathsByProperties: [String: KeyPathConvertible]? {
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
