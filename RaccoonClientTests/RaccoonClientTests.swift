//
//  RaccoonClientTests.swift
//  RaccoonClientTests
//
//  Created by Manu on 12/5/16.
//  Copyright © 2016 manuege. All rights reserved.
//

import XCTest
@testable import RaccoonClient
import Raccoon
import Alamofire
import OHHTTPStubs

class MyInsertable: NSObject, Insertable {
    var integer: Int
    var string: String
    
    typealias ContextType = NoContext
    
    init(integer: Int, string: String) {
        self.integer = integer
        self.string = string
    }
    
    static func createOne(json: [String : AnyObject], context: ContextType) throws -> AnyObject? {
        let integer = json["integer"] as! Int
        let string = json["string"] as! String
        return MyInsertable(integer: integer, string: string)
    }
    
    static func createMany(array: [AnyObject], context: ContextType) throws -> [AnyObject]? {
        return array.map({ (object) -> AnyObject in
            let json = object as! [String: AnyObject]
            return try! MyInsertable.createOne(json, context: context)!
        })
    }
}

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
    
    private static func EndpointSerializer(endpoint: Endpoint) -> Request {
        
        return request(endpoint.method,
            "\(apiUrl)\(endpoint.path)",
            parameters: endpoint.parameters,
            encoding: endpoint.encoding,
            headers: endpoint.headers)
            .validate()
    }
    
    static func create() -> Client {
        return Client(context: NoContext(), endpointSerializer: EndpointSerializer)
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
    
    //MARK: Helper
    func stubWithObject(object: AnyObject) {
        
        OHHTTPStubs.stubRequestsPassingTest({
            (request: NSURLRequest) -> Bool in
            return true
            }, withStubResponse: { (request: NSURLRequest) -> OHHTTPStubsResponse in
                return OHHTTPStubsResponse(JSONObject: object, statusCode:200, headers:nil)
        })
    }
}
