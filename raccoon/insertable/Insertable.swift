//
//  Insertable.swift
//  raccoon
//
//  Created by Manu on 21/4/16.
//  Copyright © 2016 manuege. All rights reserved.
//

import Foundation

/**
 The items that implement this protocol are able to be inserted by a raccoonResponse.
 */
public protocol Insertable: NSObjectProtocol {
    
    /**
     Some objects needs some addtional info to be inserted. This property tell the library the type of this context. If not aditional info is needed, set ti to `NoContext`
     */
    associatedtype ContextType: InsertContext
    
    /**
     Method called when object needs to be inserted as a single object. 
     - return: The new inserted objects, if any.
     */
    static func createOne(json: [String: AnyObject], context: ContextType) throws -> AnyObject?
    
    /**
     Method called when object needs to be inserted as an array of objects. 
     - return: The new inserted objects, if any.
     */
    static func createMany(array: [AnyObject], context: ContextType) throws -> [AnyObject]?

}

/** 
 The items that implement this protocol can be used as context in a raccoonResponse.
 */
public protocol InsertContext {
    
    /** 
     An object could be provide different contexts depending of the type of the object to insert.
     If not implemented, it will return `self`
     - return: The context instance for the given type. If the object can't be processed, it must returns a instance of `NoContext`
     */
    func context<T where T: Insertable>(forType _: T.Type) -> InsertContext
}

/**
 The default implementation for an `InsertContext` item. It just returns self
 */
public extension InsertContext {
    func context<T where T: Insertable>(forType _: T.Type) -> InsertContext {
        return self
    }
}

/** 
 Struct that indicates that an object doesn't need a context
 */
public struct NoContext {
    public init() {}
}

extension NoContext: InsertContext {
}
