//
//  RaccoonClientTests.swift
//  RaccoonClientTests
//
//  Created by Manu on 12/5/16.
//  Copyright © 2016 manuege. All rights reserved.
//

import XCTest
import Raccoon
import Alamofire
import OHHTTPStubs

class MyWrapper: Wrapper {
    
    var string = ""
    var insertable: MyInsertable!
    
    
    required init() {}
    
    func map(map: Map) {
        string <- map["string"]
        insertable <- map["insertable"]
    }
}

let apiUrl = "http://api.host.com/"

extension Client {
    static func create() -> Client {
        return Client(baseURL: apiUrl, context: NoContext())
    }
}

class RaccoonClientTests: XCTestCase {
    
    let client = Client.create()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }
}
