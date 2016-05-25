//
//  manuege.swift
//  manuege
//
//  Created by Manu on 11/2/16.
//  Copyright © 2016 manuege. All rights reserved.
//

import Foundation
import Alamofire

let RaccoonResponseSerializerDomain = "RaccoonResponseSerializerDomain"
let UnexpectedTypeErrorCode = -1
let InvalidContextTypeErrorCode = -2

extension Alamofire.Request {
    
    private static func raccoonBaseSerializer<ReturnType>() -> ResponseSerializer<ReturnType, NSError> {
        
        return ResponseSerializer { request, response, data, error in
            
            // Transform to json
            let jsonSerializer = JSONResponseSerializer()
            let jsonResponse = jsonSerializer.serializeResponse(request, response, data, error)
            
            guard let jsonResponseValue = jsonResponse.value else {
                return .Failure(jsonResponse.error!)
            }
            
            // convert to ReturnType type
            guard let returnObject = jsonResponseValue as? ReturnType else {
                let error = NSError(domain: RaccoonResponseSerializerDomain,
                    code: UnexpectedTypeErrorCode,
                    userInfo: [NSLocalizedFailureReasonErrorKey: "Expected type: \(ReturnType.self) received \(jsonResponseValue.dynamicType)"])
                return .Failure(error)
            }
            
            return .Success(returnObject)
        }
    }
    
    // MARK: Element
    public static func raccoonResponseSerializer<T: Insertable> (context: InsertContext = NoContext()) -> ResponseSerializer <T, NSError> {
        
        return ResponseSerializer { request, response, data, error in
            // Check if error in previous step
            guard error == nil else {
                return .Failure(error!)
            }
            
            // Transform to json
            let baseSerializer = raccoonBaseSerializer() as ResponseSerializer<[String: AnyObject], NSError>
            let baseResponse = baseSerializer.serializeResponse(request, response, data, error)
            
            guard baseResponse.isSuccess else {
                return .Failure(baseResponse.error!)
            }
            
            // Check if the context is valid
            guard let context = context.context(forType: T.self) as? T.ContextType else {
                return .Failure(NSError(domain: RaccoonResponseSerializerDomain,
                    code: InvalidContextTypeErrorCode,
                    userInfo: nil))
            }
            
            // Serialize
            do {
                let convertedObject: T = try T.createOne(baseResponse.value!, context: context) as! T
                return .Success(convertedObject)
            }
            
            catch let error as NSError {
                return .Failure(error)
            }
        }
    }
    
    public func response<T: Insertable>(context: InsertContext = NoContext(),
        completionHandler: (Response<T, NSError>) -> Void) -> Self {
            
            let serializer = Request.raccoonResponseSerializer(context) as ResponseSerializer <T, NSError>
            return response(responseSerializer: serializer, completionHandler: completionHandler)
    }
    
    // MARK: Array
    public static func raccoonResponseSerializer<T: Insertable> (context: InsertContext = NoContext()) -> ResponseSerializer <[T], NSError> {
        
        return ResponseSerializer { request, response, data, error in
            
            // Check if error in previous step
            guard error == nil else {
                return .Failure(error!)
            }
            
            // Transform to json
            let baseSerializer = raccoonBaseSerializer() as ResponseSerializer<[AnyObject], NSError>
            let baseResponse = baseSerializer.serializeResponse(request, response, data, error)
            
            guard baseResponse.isSuccess else {
                return .Failure(baseResponse.error!)
            }
            
            // Check if the context is valid
            guard let context = context.context(forType: T.self) as? T.ContextType else {
                return .Failure(NSError(domain: RaccoonResponseSerializerDomain,
                    code: InvalidContextTypeErrorCode,
                    userInfo: nil))
            }
            
            // Serialize
            do {
                let convertedObject: [T] = try T.createMany(baseResponse.value!, context: context) as! [T]
                return .Success(convertedObject)
            }
                
            catch let error as NSError {
                return .Failure(error)
            }
        }
    }

    
    public func response<T: Insertable>(context: InsertContext = NoContext(),
        completionHandler: (Response<[T], NSError>) -> Void) -> Self {
            
            let serializer = Request.raccoonResponseSerializer(context) as ResponseSerializer<[T], NSError>
            return response(responseSerializer: serializer, completionHandler: completionHandler)
    }
    
    // MARK: Wrapper
    public static func raccoonResponseSerializer<T: Wrapper> (context: InsertContext = NoContext()) -> ResponseSerializer <T, NSError> {
        
        return ResponseSerializer { request, response, data, error in
            // Transform to json
            let baseSerializer = raccoonBaseSerializer() as ResponseSerializer<[String: AnyObject], NSError>
            let baseResponse = baseSerializer.serializeResponse(request, response, data, error)
            
            guard error == nil else {
                return .Failure(error!)
            }
            
            // Convert
            let json = baseResponse.value!
            let convertedObject = T(dictionary: json, context: context)!
            
            return .Success(convertedObject)
    
        }
    }
    
    public func response<T: Wrapper>(context: InsertContext = NoContext(),
        completionHandler: (Response<T, NSError>) -> Void) -> Self {
            
            let serializer = Request.raccoonResponseSerializer(context) as ResponseSerializer<T, NSError>
            return response(responseSerializer: serializer, completionHandler: completionHandler)
    }

}
