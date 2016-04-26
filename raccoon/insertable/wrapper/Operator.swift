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
func <- <T: Insertable>(inout left: T, right: MapValue?) {
    if let mapValue = right {
        let value: T? = mapValue.serialize()
        left = value!
    }
}

func <- <T: Insertable>(inout left: T?, right: MapValue?) {
    if let mapValue = right {
        let value: T? = mapValue.serialize()
        left = value
    }
}

func <- <T: Insertable>(inout left: T!, right: MapValue?) {
    if let mapValue = right {
        let value: T? = mapValue.serialize()
        left = value
    }
}

// MARK: Array operators
func <- <T: Insertable>(inout left: [T], right: MapValue?) {
    if let mapValue = right {
        let value: [T]? = mapValue.serialize()
        left = value!
    }
}

func <- <T: Insertable>(inout left: [T]?, right: MapValue?) {
    if let mapValue = right {
        let value: [T]? = mapValue.serialize()
        left = value
    }
}

func <- <T: Insertable>(inout left: [T]!, right: MapValue?) {
    if let mapValue = right {
        let value: [T]? = mapValue.serialize()
        left = value
    }
}

// MARK: Wrapper operator
func <- <T: Wrapper>(inout left: T, right: MapValue?) {
    if let mapValue = right {
        let value: T? = mapValue.serialize()
        left = value!
    }
}

func <- <T: Wrapper>(inout left: T?, right: MapValue?) {
    if let mapValue = right {
        let value: T? = mapValue.serialize()
        left = value
    }
}

func <- <T: Wrapper>(inout left: T!, right: MapValue?) {
    if let mapValue = right {
        let value: T? = mapValue.serialize()
        left = value
    }
}

// MARK: Wrapper array
func <- <T: Wrapper>(inout left: [T], right: MapValue?) {
    if let mapValue = right {
        let value: [T]? = mapValue.serialize()
        left = value!
    }
}

func <- <T: Wrapper>(inout left: [T]?, right: MapValue?) {
    if let mapValue = right {
        let value: [T]? = mapValue.serialize()
        left = value
    }
}

func <- <T: Wrapper>(inout left: [T]!, right: MapValue?) {
    if let mapValue = right {
        let value: [T]? = mapValue.serialize()
        left = value
    }
}

// MARK: Generic operator
func <- <T>(inout left: T, right: MapValue?) {
    if let mapValue = right {
        left = mapValue.originalValue as! T
    }
}

func <- <T>(inout left: T?, right: MapValue?) {
    if let mapValue = right {
        left = mapValue.originalValue as? T
    }
}

func <- <T>(inout left: T!, right: MapValue?) {
    if let mapValue = right {
        left = mapValue.originalValue as? T
    }
}


// MARK: Generic operator with converter
// R? -> T?
func <- <T, R>(inout left: T, right: (mapValue: MapValue?, transformer: R? -> T?)) {
    if let mapValue = right.mapValue {
        let transformedValue = right.transformer(mapValue.originalValue as? R)!
        left = transformedValue as T
    }
}

func <- <T, R>(inout left: T?, right: (mapValue: MapValue?, transformer: R? -> T?)) {
    if let mapValue = right.mapValue {
        let transformedValue = right.transformer(mapValue.originalValue as? R)
        left = transformedValue
    }
}

func <- <T, R>(inout left: T!, right: (mapValue: MapValue?, transformer: R? -> T?)) {
    if let mapValue = right.mapValue {
        let transformedValue = right.transformer(mapValue.originalValue as? R)
        left = transformedValue
    }
}


// R -> T?
func <- <T, R>(inout left: T, right: (mapValue: MapValue?, transformer: R -> T?)) {
    if let mapValue = right.mapValue {
        let transformedValue = right.transformer(mapValue.originalValue as! R)!
        left = transformedValue as T
    }
}

func <- <T, R>(inout left: T?, right: (mapValue: MapValue?, transformer: R -> T?)) {
    if let mapValue = right.mapValue {
        let transformedValue = right.transformer(mapValue.originalValue as! R)
        left = transformedValue
    }
}

func <- <T, R>(inout left: T!, right: (mapValue: MapValue?, transformer: R -> T?)) {
    if let mapValue = right.mapValue {
        let transformedValue = right.transformer(mapValue.originalValue as! R)
        left = transformedValue
    }
}


// R? -> T
func <- <T, R>(inout left: T, right: (mapValue: MapValue?, transformer: R? -> T)) {
    if let mapValue = right.mapValue {
        let transformedValue = right.transformer(mapValue.originalValue as? R)
        left = transformedValue as T
    }
}

func <- <T, R>(inout left: T?, right: (mapValue: MapValue?, transformer: R? -> T)) {
    if let mapValue = right.mapValue {
        let transformedValue = right.transformer(mapValue.originalValue as? R)
        left = transformedValue
    }
}

func <- <T, R>(inout left: T!, right: (mapValue: MapValue?, transformer: R? -> T)) {
    if let mapValue = right.mapValue {
        let transformedValue = right.transformer(mapValue.originalValue as? R)
        left = transformedValue
    }
}


// R -> T
func <- <T, R>(inout left: T, right: (mapValue: MapValue?, transformer: R -> T)) {
    if let mapValue = right.mapValue {
        let transformedValue = right.transformer(mapValue.originalValue as! R)
        left = transformedValue as T
    }
}

func <- <T, R>(inout left: T?, right: (mapValue: MapValue?, transformer: R -> T)) {
    if let mapValue = right.mapValue {
        let transformedValue = right.transformer(mapValue.originalValue as! R)
        left = transformedValue
    }
}

func <- <T, R>(inout left: T!, right: (mapValue: MapValue?, transformer: R -> T)) {
    if let mapValue = right.mapValue {
        let transformedValue = right.transformer(mapValue.originalValue as! R)
        left = transformedValue
    }
}
