//
//  manuege.swift
//  manuege
//
//  Created by Manu on 11/2/16.
//  Copyright © 2016 manuege. All rights reserved.
//

import Foundation
import Alamofire

public typealias ResponseConverter = (NSURLRequest?, NSHTTPURLResponse?, NSData?, NSError?) throws -> NSData?

let RaccoonResponseSerializerDomain = "RaccoonResponseSerializerDomain"
let UnexpectedTypeErrorCode = -1
let InvalidContextTypeErrorCode = -2

extension Alamofire.Request {
    
    // MARK: - Base serializers
    private static func raccoonBaseSerializer(converter: ResponseConverter? = nil) -> ResponseSerializer<NSData?, NSError> {
        
        return ResponseSerializer { request, response, data, error in
            
            // Check if error in previous step
            guard error == nil else {
                return .Failure(error!)
            }
            
            // Convert the data
            var data = data
            if let converter = converter {
                
                do {
                    data = try converter(request, response, data, error)
                }
                    
                catch let error as NSError {
                    return .Failure(error)
                }
            }
            
            // return
            return .Success(data)
        }
    }
    
    private static func raccoonJSONSerializer<ReturnType>(converter: ResponseConverter? = nil) -> ResponseSerializer<ReturnType, NSError> {
        
        return ResponseSerializer { request, response, data, error in
            
            // Base response
            let baseSerializer = raccoonBaseSerializer(converter)
            let baseResponse = baseSerializer.serializeResponse(request, response, data, error)
            
            guard baseResponse.isSuccess else {
                return .Failure(baseResponse.error!)
            }
            
            let data = baseResponse.value!
            
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
    
    // MARK: - Element
    public func response<T: Insertable>(type: T.Type, context: InsertContext = NoContext(), converter: ResponseConverter? = nil,
        completionHandler: (Response<T, NSError>) -> Void) -> Self {
            
        let serializer = Request.raccoonJSONSerializer(converter) as ResponseSerializer<[String: AnyObject], NSError>
        
        return response(responseSerializer: serializer,
                        completionHandler: { (baseResponse) in
                            
                            guard baseResponse.result.isSuccess else {
                                callHandler(completionHandler, response: baseResponse, result: .Failure(baseResponse.result.error!))
                                return
                            }
                            
                            // Check if the context is valid
                            guard let context = context.context(forType: T.self) as? T.ContextType else {
                                let error = NSError(domain: RaccoonResponseSerializerDomain,
                                    code: InvalidContextTypeErrorCode,
                                    userInfo: nil)
                                callHandler(completionHandler, response: baseResponse, result: .Failure(error))
                                return
                            }
                            
                            // Serialize
                            do {
                                let convertedObject: T = try T.createOne(baseResponse.result.value!, context: context) as! T
                                callHandler(completionHandler, response: baseResponse, result: .Success(convertedObject))
                            }
                                
                            catch let error as NSError {
                                callHandler(completionHandler, response: baseResponse, result: .Failure(error))
                            }
                            
        })

    }
    
    // MARK: - Array
    public func response<T: Insertable>(type: [T].Type, context: InsertContext = NoContext(), converter: ResponseConverter? = nil,
        completionHandler: (Response<[T], NSError>) -> Void) -> Self {
            
        let serializer = Request.raccoonJSONSerializer(converter) as ResponseSerializer<[AnyObject], NSError>
        
        return response(responseSerializer: serializer,
                        completionHandler: { (baseResponse) in
                            
                            guard baseResponse.result.isSuccess else {
                                callHandler(completionHandler, response: baseResponse, result: .Failure(baseResponse.result.error!))
                                return
                            }
                            
                            // Check if the context is valid
                            guard let context = context.context(forType: T.self) as? T.ContextType else {
                                let error = NSError(domain: RaccoonResponseSerializerDomain,
                                    code: InvalidContextTypeErrorCode,
                                    userInfo: nil)
                                callHandler(completionHandler, response: baseResponse, result: .Failure(error))
                                return
                            }
                            
                            // Serialize
                            do {
                                let convertedObject: [T] = try T.createMany(baseResponse.result.value!, context: context) as! [T]
                                callHandler(completionHandler, response: baseResponse, result: .Success(convertedObject))
                            }
                                
                            catch let error as NSError {
                                callHandler(completionHandler, response: baseResponse, result: .Failure(error))
                            }

        })
    }
    
    // MARK: - Wrapper
    public func response<T: Wrapper>(type: T.Type, context: InsertContext = NoContext(), converter: ResponseConverter? = nil,
        completionHandler: (Response<T, NSError>) -> Void) -> Self {
            
        let serializer = Request.raccoonJSONSerializer(converter) as ResponseSerializer<[String: AnyObject], NSError>
        
        return response(responseSerializer: serializer,
            completionHandler: { (response) in
                
                guard response.result.isSuccess else {
                    callHandler(completionHandler, response: response, result: .Failure(response.result.error!))
                    return
                }
                
                let json = response.result.value!
                let convertedObject = T(dictionary: json, context: context)!
                callHandler(completionHandler, response: response, result: .Success(convertedObject))
        })
    }
    
    public func response<T: Wrapper>(type: [T].Type, context: InsertContext = NoContext(), converter: ResponseConverter? = nil,
                         completionHandler: (Response<[T], NSError>) -> Void) -> Self {
        
        let serializer = Request.raccoonJSONSerializer(converter) as ResponseSerializer<[[String: AnyObject]], NSError>
        
        return response(responseSerializer: serializer,
                        completionHandler: { (response) in
                            
                            guard response.result.isSuccess else {
                                callHandler(completionHandler, response: response, result: .Failure(response.result.error!))
                                return
                            }
                            
                            let json = response.result.value!
                            let array = T.fromArray(json, context: context)
                            callHandler(completionHandler, response: response, result: .Success(array))
        })
    }
    
    // MARK: - Empty
    public func emptyResponse(converter: ResponseConverter? = nil,
                              completionHandler: (EmptyResponse) -> Void) -> Self {
        
        let serializer = Request.raccoonBaseSerializer(converter) as ResponseSerializer<NSData?, NSError>
        return response(responseSerializer: serializer,
                        completionHandler: { (response) in
                            
                            if response.result.isSuccess {
                                completionHandler(.Success)
                            }
                                
                            else {
                                completionHandler(.Failure(error: response.result.error!))
                            }
        })
    }
}

private func callHandler<O, R>(handler: (Response<R, NSError>) -> Void, response: Response<O, NSError>, result: Result<R, NSError>) {
    handler(Response(request: response.request,
        response: response.response,
        data: response.data,
        result: result))
}

public enum EmptyResponse {
    case Success
    case Failure(error: NSError)
    
    var isSuccess: Bool {
        switch self {
        case .Success:
            return true
        default:
            return false
        }
    }
    
    var isFailure: Bool {
        return !self.isSuccess
    }
}


