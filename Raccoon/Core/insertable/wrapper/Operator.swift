//
//  Operator.swift
//  manuege
//
//  Created by Manu on 15/2/16.
//  Copyright © 2016 manuege. All rights reserved.
//

import Foundation

infix operator <- {}

// MARK: Element Operator
public func <- <T: Insertable>(inout left: T, right: MapValue?) {
    if let mapValue = right {
        let value: T? = mapValue.serialize()
        left = value!
    }
}

public func <- <T: Insertable>(inout left: T?, right: MapValue?) {
    if let mapValue = right {
        let value: T? = mapValue.serialize()
        left = value
    }
}

public func <- <T: Insertable>(inout left: T!, right: MapValue?) {
    if let mapValue = right {
        let value: T? = mapValue.serialize()
        left = value
    }
}

// MARK: Array operators
public func <- <T: Insertable>(inout left: [T], right: MapValue?) {
    if let mapValue = right {
        let value: [T]? = mapValue.serialize()
        left = value!
    }
}

public func <- <T: Insertable>(inout left: [T]?, right: MapValue?) {
    if let mapValue = right {
        let value: [T]? = mapValue.serialize()
        left = value
    }
}

public func <- <T: Insertable>(inout left: [T]!, right: MapValue?) {
    if let mapValue = right {
        let value: [T]? = mapValue.serialize()
        left = value
    }
}


// MARK: Wrapper operator
public func <- <T: Wrapper>(inout left: T, right: MapValue?) {
    if let mapValue = right {
        let value: T? = mapValue.serialize()
        left = value!
    }
}

public func <- <T: Wrapper>(inout left: T?, right: MapValue?) {
    if let mapValue = right {
        let value: T? = mapValue.serialize()
        left = value
    }
}

public func <- <T: Wrapper>(inout left: T!, right: MapValue?) {
    if let mapValue = right {
        let value: T? = mapValue.serialize()
        left = value
    }
}

// MARK: Wrapper array
public func <- <T: Wrapper>(inout left: [T], right: MapValue?) {
    if let mapValue = right {
        let value: [T]? = mapValue.serialize()
        left = value!
    }
}

public func <- <T: Wrapper>(inout left: [T]?, right: MapValue?) {
    if let mapValue = right {
        let value: [T]? = mapValue.serialize()
        left = value
    }
}

public func <- <T: Wrapper>(inout left: [T]!, right: MapValue?) {
    if let mapValue = right {
        let value: [T]? = mapValue.serialize()
        left = value
    }
}

// MARK: Generic operator
public func <- <T>(inout left: T, right: MapValue?) {
    left <- (right, { $0 })
}

// MARK: Generic operator with converter
public func <- <T, R>(inout left: T, right: (mapValue: MapValue?, transformer: R -> T)) {
    
    guard let mapValue = right.mapValue else {
        return
    }
    
    let originalValue = mapValue.originalValue as! R
    let transformedValue = right.transformer(originalValue)
    left = transformedValue as T
}

public func <- <T: NilLiteralConvertible, R>(inout left: T, right: (mapValue: MapValue?, transformer: R -> T)) {
    
    guard let mapValue = right.mapValue else {
        return
    }
    
    guard let originalValue = mapValue.originalValue else {
        left = nil
        return
    }
    
    let transformedValue = right.transformer(originalValue as! R)
    left = transformedValue as T
}