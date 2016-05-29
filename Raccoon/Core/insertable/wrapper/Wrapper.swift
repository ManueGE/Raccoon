//
//  Wrapper.swift
//  manuege
//
//  Created by Manu on 15/2/16.
//  Copyright © 2016 manuege. All rights reserved.
//

import Foundation

/**
 Types that implement this protocol can be converted with a RaccoonResponse.
 */
public protocol Wrapper {
    
    /**
     required for instantiate new instances
     */
    init()
    
    /**
     Override to add the values from the given map to the receiver
     Properties must be set using the `<-` operator
     */
    mutating func map(map: Map)
    
}

extension Wrapper {
    
    /**
     Create a new instance with the content of a dictionary
     */
    public init?(dictionary: [String: AnyObject], context: InsertContext = NoContext()) {
        self.init()
        
        let map = Map(dictionary: dictionary, context: context)
        self.map(map)
    }
}

public enum MapKeyPath {
    case Root
    case Path(keyPath: String)
}

/**
 A struct that store a `NSDictionary` whose values can be serialized to different types, including `Insertable`, `Wrapper` or arrays of these types using the `serialize` methods.
 */
public struct Map {
    
    /// The original dictionary whose values will be serialized
    public var dictionary: [String: AnyObject]
    
    /**
     The context that will be used to insert the Insertable objects
     */
    public var context: InsertContext
    
    /**
     - returns: a MapValue with the value at the given keypath. If the receiver doesn't have any value at this keypath it returns nil. If the value at the keypath is `NSNull` it will return a MapValue with a nil value
     */
    public subscript(keyPath: String) -> MapValue? {
        return self[.Path(keyPath: keyPath)]
    }
    
    /**
     - returns: a MapValue with the value at the given keypath. If the receiver doesn't have any value at this keypath it returns nil. If the value at the keypath is `NSNull` it will return a MapValue with a nil value
     */
    public subscript(keyPath: MapKeyPath) -> MapValue? {
    
        var originalValue: AnyObject?
        
        switch keyPath {
        case .Root:
            originalValue = dictionary
        case .Path(let stringKeyPath):
            originalValue = (dictionary as NSDictionary).valueForKeyPath(stringKeyPath)
        }
        
        switch originalValue {
        case nil:
            return nil
        case _ as NSNull:
            return MapValue(originalValue: nil, context: context)
        default:
            return MapValue(originalValue: originalValue, context: context)
        }
    
    
    }
}

/**
 Struct that put together a value and a `InsertContext`.
 It can serialize the original value to other types, including `Insertable`, `Wrapper` or arrays of these types using the `serialize` methods.
 */
public struct MapValue {
    
    /// The original value to serialize
    public private(set) var originalValue: AnyObject?
    
    /// The context that will be used to insert the `Insertable` objects
    var context: InsertContext
    
    /**
     Serialize the receiver to a `Insertable` item
     - returns: The serialized and inserted object, nil if there is any error
     */
    internal func serialize<T: Insertable>() -> T? {
        
        guard let context = context.context(forType: T.self) as? T.ContextType else {
            fatalError("context must be set to a \(T.ContextType.self) to convert into \(T.self)")
        }
        
        let value = originalValue as! [String: AnyObject]
        return try? T.createOne(value, context: context) as! T
    }
    
    /**
     Serialize the receiver to an array of a `Insertable`
     - returns: The serialized and inserted objects, nil if there is any error
     */
    internal func serialize<T: Insertable>() -> [T]? {
        
        guard let context = context as? T.ContextType else {
            fatalError("context must be set to a \(T.ContextType.self) to convert into \(T.self) array")
        }
        
        let array = originalValue as! [[String: AnyObject]]
        return try? T.createMany(array, context: context) as! [T]
    }
    
    /**
     Serialize the receiver to a `Wrapper` object
     - returns: The serialized object, nil if there is any error
     */
    internal func serialize<T: Wrapper>() -> T? {
        let value = originalValue as! [String: AnyObject]
        return T(dictionary: value, context: context)
    }
    
    /**
     Serialize the receiver to an array of a `Wrapper` object
     - returns: The serialized objects, nil if there is any error
     */
    internal func serialize<T: Wrapper>() -> [T]? {
        
        let array = originalValue as! [[String: AnyObject]]
        
        let convertedArray = array.map({ T(dictionary: $0, context: context)! })
        return convertedArray
    }
    
    /*
    internal func mapped<T>() -> T? {
        return originalValue as? T
    }
     */
}
