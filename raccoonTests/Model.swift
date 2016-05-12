//
//  Model.swift
//  raccoon
//
//  Created by Manu on 21/4/16.
//  Copyright © 2016 manuege. All rights reserved.
//

import Foundation
@testable import Raccoon

class DateConverter {
    static let formatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    class func string(fromDate date: NSDate) -> String {
        return formatter.stringFromDate(date)
    }
    
    class func date(fromString string: String) -> NSDate {
        return formatter.dateFromString(string)!
    }
}

class Transformer {
    
    static func EnsureOptionalInteger(value: Any) -> Int? {
        switch value {
        case let string as String:
            return Int(string)
        case let int as Int:
            return int
        default:
            return nil
        }
    }
    
    static func EnsureInteger(value: Any) -> Int {
        switch value {
        case let string as String:
            return Int(string)!
        case let int as Int:
            return int
        default:
            return 0
        }
    }
    
}

class Pagination: Wrapper {
    
    var limit: Int = 0
    var offset: Int? = 0
    var total: Int! = 0
    
    required init() {}
    
    func map(map: Map) {
        limit <- (map["limit"], Transformer.EnsureInteger)
        offset <- (map["offset"], Transformer.EnsureOptionalInteger)
        total <- map["total"]
    }
}

class Response: Wrapper {
    var string: String!
    var date: NSDate?
    var pagination: Pagination?
    var paginations: [Pagination]?
    
    required init() {}
    
    func map(map: Map) {
        string <- map["string"]
        date <- (map["date"], DateConverter.date)
        pagination <- map["pagination"]
        paginations <- map["paginations"]
    }
}

class PaginatedResponse<Type: Insertable>: Wrapper {
    
    var data: [Type]!
    var pagination: Pagination!
    
    required init() {}
    
    func map(map: Map) {
        data <- map["data"]
        pagination <- map[.Root]
    }
}
