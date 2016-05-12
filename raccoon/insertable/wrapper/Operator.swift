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

func <- <T: NilLiteralConvertible>(inout left: T, right: MapValue?) {
    if let mapValue = right {
        left = mapValue.originalValue as? T
    }
}

// MARK: Generic operator with converter
func <- <T, R>(inout left: T, right: (mapValue: MapValue?, transformer: R -> T)) {
    
    guard let mapValue = right.mapValue else {
        return
    }
    
    guard let originalValue = mapValue.originalValue as? R else {
        return
    }
    
    let transformedValue = right.transformer(originalValue)
    left = transformedValue as T
}

func <- <T: NilLiteralConvertible, R>(inout left: T, right: (mapValue: MapValue?, transformer: R -> T)) {
    
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