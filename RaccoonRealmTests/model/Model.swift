//
//  RealmModel.swift
//  raccoon
//
//  Created by Manu on 21/4/16.
//  Copyright © 2016 manuege. All rights reserved.
//

import Foundation
@testable import RaccoonRealm
import RealmSwift
import Raccoon

struct DateConverter {
    static let formatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    static func string(fromDate date: NSDate) -> String {
        return formatter.stringFromDate(date)
    }
    
    static func date(fromString string: String) -> NSDate {
        return formatter.dateFromString(string)!
    }
}

class User: Object {
    dynamic var id: Int = 0
    dynamic var name: String = ""
    dynamic var country: String = ""
    dynamic var birthday: NSDate? = nil
    
    override static func indexedProperties() -> [String] {
        return ["id"]
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override class var keyPathsByProperties: [String: KeyPathConvertible]? {
        return [
            "id": "id",
            "name": "Nombre",
            "birthday": KeyPathTransformer(keyPath: "birthday", transformer:DateConverter.date),
            "country": "address.country"
        ]
    }
}

class Role: Object {
    dynamic var id: Int = 0
    dynamic var name: String = ""
    
    override static func indexedProperties() -> [String] {
        return ["id"]
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
