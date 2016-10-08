//
//  Endpoint.swift
//  raccoon
//
//  Created by Manuel García-Estañ on 8/10/16.
//  Copyright © 2016 manuege. All rights reserved.
//

import Foundation
import Alamofire

public protocol Endpoint {
    func request(withBaseURL baseURL: String) -> DataRequest
}
